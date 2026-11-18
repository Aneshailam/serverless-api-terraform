import json
import os
import uuid
from datetime import datetime, timezone

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

HEADERS = {"Content-Type": "application/json"}


def response(status, body):
    return {"statusCode": status, "headers": HEADERS, "body": json.dumps(body)}


def lambda_handler(event, context):
    try:
        data = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return response(400, {"error": "Body must be valid JSON"})

    name = str(data.get("name", "")).strip()
    if not name:
        return response(400, {"error": "Field 'name' is required"})
    if len(name) > 200:
        return response(400, {"error": "Field 'name' is too long (max 200)"})

    item = {
        "id": str(uuid.uuid4()),
        "name": name,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    table.put_item(Item=item)
    return response(201, item)
