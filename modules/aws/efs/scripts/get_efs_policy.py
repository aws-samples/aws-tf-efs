import sys
import json
import logging
import boto3
from botocore.exceptions import ClientError

# Test: python .\get_efs_policy.py '{\"file_system_id\": \"fs-0c6cf7718c6659521\"}'

result1 = {
    "file_system_id": "",
    "policy": "",
    "error": ""
}

try:
    input_str = sys.stdin.read()
    # use argv during testing
    #input_str = sys.argv[1]
    input_json = json.loads(input_str)
    file_system_id = input_json.get("file_system_id")
    aws_region = input_json.get("aws_region")
    client = boto3.client('efs', region_name=aws_region)
    response = client.describe_file_system_policy(FileSystemId=file_system_id)
    #res_json = json.loads(response.get("Policy"))
    result = {
        "file_system_id": file_system_id,
        "policy": response.get("Policy"),
        "error": ""
    }
except ClientError as e:
    result = {
        "file_system_id": file_system_id,
        "policy": "",
        "error": f'Error: {e}'
    }

print(json.dumps(result, indent=2))
