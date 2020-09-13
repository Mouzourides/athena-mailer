#!/usr/bin/env python
import boto3
import time
from datetime import date

athena_client = boto3.client('athena')
email_client = boto3.client('ses')


def handler(event, context):
    query = athena_client.start_query_execution(
        QueryString="SELECT COUNT(*) FROM nikmouz_website_logs",
        ResultConfiguration={
            "OutputLocation": "s3://nikmouz-athena-query-results"
        }
    )
    query_execution_id = query["QueryExecutionId"]

    try:
        check_query_state_until_ready(query_execution_id)

        query_results = athena_client.get_query_results(QueryExecutionId=query_execution_id)
        result = query_results["ResultSet"]["Rows"][1]["Data"][0]["VarCharValue"]
        traffic_result = "Total traffic: " + result
        print(traffic_result)

        send_email(traffic_result)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": {
                "message": str(e)
            }
        }

    return {
        "statusCode": 200,
        "body": {
            "message": traffic_result
        }
    }


def check_query_state_until_ready(query_execution_id):
    query_exec_results = athena_client.get_query_execution(QueryExecutionId=query_execution_id)
    status_state = query_exec_results['QueryExecution']['Status']['State']

    if status_state == 'QUEUED' or status_state == 'RUNNING':
        print("Not ready yet...")
        time.sleep(5)
        check_query_state_until_ready(query_execution_id)
    if status_state == 'FAILED':
        print(query_exec_results)
        raise Exception("Failed to execute query: "
                        + str(query_exec_results["QueryExecution"]["Status"]["StateChangeReason"]))


def send_email(data):
    email_client.send_email(
        Source='Log Stats - nikmouz.dev <log-stats@nikmouz.dev>',
        Destination={
            'ToAddresses': ['***REMOVED***']
        },
        Message={
            'Subject': {
                'Data': f'Log stats from nikmouz.dev at {date.today()}'
            },
            'Body': {
                'Text': {
                    'Data': data
                }
            }
        })


if __name__ == '__main__':
    handler(None, None)
