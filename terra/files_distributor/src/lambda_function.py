import json

import requests


def lambda_handler(event, context):
    print(event)

    ingress_request = event["Records"][0]["cf"]["request"]
    print(ingress_request)

    ingress_headers = ingress_request["headers"]
    print(ingress_headers)

    try:
        pass
    except:
        pass

    return ingress_request
