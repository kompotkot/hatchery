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
BUGOUT_APPLICATION_ID = "0270c582-f3be-4658-af78-44a3647cb2a1"


s3 = boto3.client("s3")


def make_request(method: str, url: str, **kwargs):
    response_body = None
    try:
        r = requests.request(method, url=url, **kwargs)
        r.raise_for_status()
        response_body = r.json()
    except Exception:
        raise Exception()
    return response_body


def get_image_from_bucket(journal_id: str, entry_id: str, image_id: str) -> str:
    image_path = f"{BUGOUT_FILES_S3_BUCKET_PREFIX}/{journal_id}/entries/{entry_id}/images/{image_id}"
    response = s3.get_object(Bucket=BUGOUT_FILES_S3_BUCKET_NAME, Key=image_path)
    image = response["Body"].read()
    encoded_image = base64.b64encode(image)
    return encoded_image


def put_image_to_bucket(
    journal_id: str,
    entry_id: str,
    image_id: UUID,
    decoded_body: bytes,
    headers: dict,
) -> None:
    _, c_data = parse_header(headers["content-type"])
    c_data["boundary"] = bytes(c_data["boundary"], "utf-8")
    c_data["CONTENT-LENGTH"] = headers["content-length"]
    form_data = parse_multipart(BytesIO(decoded_body), c_data)

    for image_str in form_data["file"]:
        image_path = f"{BUGOUT_FILES_S3_BUCKET_PREFIX}/{journal_id}/entries/{entry_id}/images/{str(image_id)}"
        s3.put_object(
            Body=image_str, Bucket=BUGOUT_FILES_S3_BUCKET_NAME, Key=image_path
        )


def lambda_handler(event, context):
    method = event["httpMethod"]
    params = event["queryStringParameters"]
    headers = event["headers"]
    auth_bearer_header = headers["authorization"]

    path = event["path"]
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
    try:
        entry_url = f"{BUGOUT_SPIRE_URL}/journals/{journal_id}/entries/{entry_id}"
        entry = make_request(
            method="GET", url=entry_url, headers={"authorization": auth_bearer_header}
        )
    except Exception:
        return {"statusCode": 403}

    resources_url = f"{BUGOUT_BROOD_URL}/resources/"

    # Download image
    if method == "GET":
        if len(path_list) == 6:
            # Get image
            image_id = path_list[5]
            try:
                encoded_image = get_image_from_bucket(journal_id, entry_id, image_id)
                return {
                    "statusCode": 200,
                    "headers": {"Content-Type": "image/png"},
                    "body": encoded_image,
                    "isBase64Encoded": True,
                }
            except Exception:
                print(f"Error due retrieving image with id: {image_id} from bucket")
                return {"statusCode": 500}

        elif len(path_list) == 5:
            # List images for entry
            image_params = {
                "application_id": BUGOUT_APPLICATION_ID,
                "journal_id": journal_id,
                "entry_id": entry_id,
            }
            try:
                resources = make_request(
                    method="GET",
                    url=resources_url,
                    headers={"authorization": auth_bearer_header},
                    params=image_params,
                )
                resources_data = [
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
                return {
                    "statusCode": 200,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps(resources_data),
                }
            except Exception:
                print(
                    f"Error due retrieving resources for journal with id: {journal_id} and entry with id: {entry_id}"
                )
                return {"statusCode": 500}
        else:
            return {"statusCode": 404}

    elif method == "POST":
        # Upload image to S3 bucket
        image_id = uuid4()
        image_name = params["image_name"]
        image_extension = params["image_extension"]

        # Create new resource record
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
                body_raw = event["body"]
                decoded_body = base64.b64decode(body_raw)
                put_image_to_bucket(
                    journal_id=journal_id,
                    entry_id=entry_id,
                    image_id=image_id,
                    decoded_body=decoded_body,
                    headers=headers,
                )
                return {
                    "statusCode": 200,
                    "body": json.dumps(resource["resource_data"]),
                }
            except Exception:
                print(
                    f"Error due saving resource with id: {resource['id']} image with id: {str(image_id)} to bucket"
                )
                return {"statusCode": 500}
        except Exception:
            print(f"Error due creating resource")
            return {"statusCode": 403}

        return {"statusCode": 200}

    return {"statusCode": 404}
