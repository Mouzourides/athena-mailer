#!/usr/bin/env python
import requests

def handler(event, context):
    response_body = {
        "statusCode": 200,
        "body": {
            "message": "hello world"
        }
    }
    print(response_body)
    return response_body


if __name__ == '__main__':
    handler(None, None)
