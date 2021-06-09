import json


def lambda_function(event, context):
    ingress_request = event["Records"][0]["cf"]["request"]

    return ingress_request
