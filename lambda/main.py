#!/usr/bin/env python
import boto3
import time

client = boto3.client('athena')


def handler(event, context):
    query = client.start_query_execution(
        QueryString="SELECT COUNT(*) FROM nikmouz_website_logs",
        ResultConfiguration={
            "OutputLocation": "s3://nikmouz-athena-query-results"
        }
    )
    query_execution_id = query["QueryExecutionId"]
    check_query_state_until_ready(query_execution_id)

    query_results = client.get_query_results(QueryExecutionId=query_execution_id)
    result = query_results["ResultSet"]["Rows"][1]["Data"][0]["VarCharValue"]
    print("Total traffic: " + result)

    response_body = {
        "statusCode": 200,
        "body": {
            "Total traffic": result
        }
    }
    return response_body


def check_query_state_until_ready(query_execution_id):
    query_exec_results = client.get_query_execution(QueryExecutionId=query_execution_id)
    status_state = query_exec_results['QueryExecution']['Status']['State']

    if (status_state == 'QUEUED' or status_state == 'RUNNING'):
        print("Not ready yet...")
        time.sleep(5)
        check_query_state_until_ready(query_execution_id)


if __name__ == '__main__':
    handler(None, None)
