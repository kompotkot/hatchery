import base64
import boto3
from cgi import parse_multipart, parse_header
from datetime import datetime
import json
from io import BytesIO
from uuid import uuid4, UUID

import requests

BUGOUT_SPIRE_URL = "https://spire.bugout.dev"
BUGOUT_BROOD_URL = "https://auth.bugout.dev"
BUGOUT_FILES_S3_BUCKET_NAME = "hatchery-files"
BUGOUT_FILES_S3_BUCKET_PREFIX = "dev"
BUGOUT_APPLICATION_ID = "a218415d-0431-44c5-bc0f-c7b2319c62fd"


s3 = boto3.client("s3")


class BugoutResponseException(Exception):
    def __init__(self, message, status_code, detail=None) -> None:
        super().__init__(message)
        self.status_code = status_code
        if detail is not None:
            self.detail = detail


def make_request(method: str, url: str, **kwargs) -> dict:
    try:
        r = requests.request(method, url=url, **kwargs)
        r.raise_for_status()
        response_body = r.json()
    except requests.exceptions.RequestException as err:
        raise BugoutResponseException(err, status_code=r.status_code, detail=r.reason)
    except Exception as err:
        raise Exception("Unexpected error occurred due calling to Bugout API")

    return response_body


def get_image_from_bucket(journal_id: str, entry_id: str, image_id: str) -> bytes:
    image_path = f"{BUGOUT_FILES_S3_BUCKET_PREFIX}/{journal_id}/entries/{entry_id}/images/{image_id}"
    response = s3.get_object(Bucket=BUGOUT_FILES_S3_BUCKET_NAME, Key=image_path)
    image = response["Body"].read()
    encoded_image = base64.b64encode(image)
    return encoded_image


def delete_image_from_bucket(journal_id: str, entry_id: str, image_id: str) -> None:
    image_path = f"{BUGOUT_FILES_S3_BUCKET_PREFIX}/{journal_id}/entries/{entry_id}/images/{image_id}"
    s3.delete_object(Bucket=BUGOUT_FILES_S3_BUCKET_NAME, Key=image_path)


def put_image_to_bucket(
    journal_id: str,
    entry_id: str,
    image_id: UUID,
    content_type: str,
    content_length: int,
    decoded_body: bytes,
) -> bool:
    _, c_data = parse_header(content_type)
    c_data["boundary"] = bytes(c_data["boundary"], "utf-8")
    c_data["CONTENT-LENGTH"] = content_length

    form_data = parse_multipart(BytesIO(decoded_body), c_data)

    for image_str in form_data["file"]:
        image_path = f"{BUGOUT_FILES_S3_BUCKET_PREFIX}/{journal_id}/entries/{entry_id}/images/{str(image_id)}"
        s3.put_object(
            Body=image_str, Bucket=BUGOUT_FILES_S3_BUCKET_NAME, Key=image_path
        )
    return


def lambda_handler(event, context):
    path = event["path"]
    if path == "/ping":
        return {"statusCode": 200, "body": json.dumps({"status": "ok"})}
    path_list = path.lstrip("/").rstrip("/").split("/")
    try:
        assert path_list[0] == "files"
        journal_id = path_list[1]
        assert path_list[2] == "entries"
        entry_id = path_list[3]
        assert path_list[4] == "images"
    except Exception:
        return {"statusCode": 404}

    # Check access permissions
    headers = event["headers"]
    auth_bearer_header = headers["authorization"]
    try:
        entry_url = f"{BUGOUT_SPIRE_URL}/journals/{journal_id}/entries/{entry_id}"
        make_request(
            method="GET", url=entry_url, headers={"authorization": auth_bearer_header}
        )
    except BugoutResponseException as err:
        return {"statusCode": err.status_code, "body": err.detail}
    except Exception as err:
        print(err)
        return {"statusCode": 500}

    method = event["httpMethod"]
    params = event["queryStringParameters"]

    resources_url = f"{BUGOUT_BROOD_URL}/resources/"
    image_params = {
        "application_id": BUGOUT_APPLICATION_ID,
        "journal_id": journal_id,
        "entry_id": entry_id,
    }

    # Download image
    if method == "GET":
        # Get image
        if len(path_list) == 6:
            image_id = path_list[5]
            try:
                image_params.update({"id": image_id})
                resources = make_request(
                    method="GET",
                    url=resources_url,
                    headers={"authorization": auth_bearer_header},
                    params=image_params,
                )
                assert str(resources["resources"][0]["resource_data"]["id"]) == image_id
                resource = resources["resources"][0]
                image_name = resource["resource_data"]["name"]
                image_extension = resource["resource_data"]["extension"]
                try:
                    encoded_image = get_image_from_bucket(
                        journal_id, entry_id, image_id
                    )
                    return {
                        "statusCode": 200,
                        "headers": {
                            "Content-Type": f"image/{image_extension}"
                            if image_extension != "jpg"
                            else "image/jpeg",
                            "x-bugout-image-fullname": f"{image_name}.{image_extension}",
                        },
                        "body": encoded_image,
                        "isBase64Encoded": True,
                    }
                except Exception as err:
                    print(f"Error due retrieving image with id: {image_id} from bucket")
                    print(err)
                    return {"statusCode": 500}
            except BugoutResponseException as err:
                return {"statusCode": err.status_code, "body": err.detail}
            except Exception as err:
                print(f"Error due retrieving image with id: {image_id} from resource")
                print(err)
                return {"statusCode": 500}

        # List images for entry
        elif len(path_list) == 5:
            try:
                resources = make_request(
                    method="GET",
                    url=resources_url,
                    headers={"authorization": auth_bearer_header},
                    params=image_params,
                )
                resources_data = {
                    "images": [
                        {
                            "id": resource["resource_data"]["id"],
                            "journal_id": resource["resource_data"]["journal_id"],
                            "entry_id": resource["resource_data"]["entry_id"],
                            "name": resource["resource_data"]["name"],
                            "extension": resource["resource_data"]["extension"],
                            "created_at": resource["resource_data"]["created_at"],
                        }
                        for resource in resources["resources"]
                    ]
                }
                return {
                    "statusCode": 200,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps(resources_data),
                }
            except BugoutResponseException as err:
                return {"statusCode": err.status_code, "body": err.detail}
            except Exception as err:
                print(
                    f"Error due list resources for journal with id: {journal_id} and entry with id: {entry_id}"
                )
                print(err)
                return {"statusCode": 500}

    # Upload image to S3 bucket
    elif method == "POST":
        image_id = uuid4()
        image_fullname = params["image_name"]
        image_fullname_list = image_fullname.split(".")
        if len(image_fullname_list) < 2:
            return {
                "statusCode": 406,
                "body": json.dumps({"error": "Unacceptable image name"}),
            }
        image_name = "_".join(image_fullname_list[:-1]).lower()
        image_extension = image_fullname_list[-1].lower()
        if image_extension not in ["png", "jpg", "jpeg", "bmp", "gif"]:
            return {
                "statusCode": 406,
                "body": json.dumps({"error": "Unacceptable image extension"}),
            }

        json_data = {
            "application_id": BUGOUT_APPLICATION_ID,
            "resource_data": {
                "id": str(image_id),
                "entry_id": entry_id,
                "journal_id": journal_id,
                "name": image_name,
                "extension": image_extension,
                "created_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f"),
            },
        }
        try:
            resource = make_request(
                method="POST",
                url=resources_url,
                headers={"authorization": auth_bearer_header},
                json=json_data,
            )
            try:
                content_type = headers["content-type"]
                body_raw = event["body"]
                decoded_body = base64.b64decode(body_raw)
                try:
                    content_length = headers["content-length"]
                except Exception:
                    content_length = len(decoded_body)
                if content_length > 5500000:
                    print("Image too large")
                    return {"statusCode": 406}

                put_image_to_bucket(
                    journal_id=journal_id,
                    entry_id=entry_id,
                    image_id=image_id,
                    content_type=content_type,
                    content_length=content_length,
                    decoded_body=decoded_body,
                )
                return {
                    "statusCode": 200,
                    "body": json.dumps(resource["resource_data"]),
                }
            except Exception as err:
                print(
                    f"Error due saving image with id: {str(image_id)} for resource with id: {resource['id']} to bucket"
                )
                print(err)
                return {"statusCode": 500}
        except BugoutResponseException as err:
            return {"statusCode": err.status_code, "body": err.detail}
        except Exception as err:
            print(
                f"Error due creating resource for journal with id: {journal_id} and entry with id: {entry_id}"
            )
            print(err)
            return {"statusCode": 500}

    # Delete image
    elif method == "DELETE":
        if len(path_list) == 6:
            image_id = path_list[5]
            try:
                image_params.update({"id": image_id})
                resources = make_request(
                    method="GET",
                    url=resources_url,
                    headers={"authorization": auth_bearer_header},
                    params=image_params,
                )
                assert str(resources["resources"][0]["resource_data"]["id"]) == image_id
                resource = resources["resources"][0]
                try:
                    make_request(
                        method="DELETE",
                        url=f"{resources_url}{resource['id']}",
                        headers={"authorization": auth_bearer_header},
                    )
                except BugoutResponseException as err:
                    return {"statusCode": err.status_code, "body": err.detail}
                except Exception as err:
                    print(f"Error due deleting resource with id: {resource['id']}")
                    print(err)
                    return {"statusCode": 500}
                try:
                    delete_image_from_bucket(journal_id, entry_id, image_id)
                except Exception as err:
                    print(f"Error due deleting image with id: {image_id} from bucket")
                    print(err)
                    return {"statusCode": 500}
                return {
                    "statusCode": 200,
                    "body": json.dumps(resource["resource_data"]),
                }
            except BugoutResponseException as err:
                return {"statusCode": err.status_code, "body": err.detail}
            except Exception as err:
                print(f"Resource for image with id: {image_id} not found")
                print(err)
                return {"statusCode": 500}

    return {"statusCode": 404}
