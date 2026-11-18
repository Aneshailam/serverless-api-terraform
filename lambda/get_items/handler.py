import json
import os

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

HEADERS = {"Content-Type": "application/json"}


def lambda_handler(event, context):
    result = table.scan(Limit=100)
    items = sorted(result.get("Items", []), key=lambda i: i.get("created_at", ""))
    return {
        "statusCode": 200,
        "headers": HEADERS,
        "body": json.dumps({"items": items}, default=str),
    }
