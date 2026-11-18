import json
import os

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

HEADERS = {"Content-Type": "application/json"}


def lambda_handler(event, context):
    item_id = (event.get("pathParameters") or {}).get("id")
    if not item_id:
        return {
            "statusCode": 400,
            "headers": HEADERS,
            "body": json.dumps({"error": "Item id is required"}),
        }

    table.delete_item(Key={"id": item_id})
    return {"statusCode": 200, "headers": HEADERS, "body": json.dumps({"deleted": item_id})}
