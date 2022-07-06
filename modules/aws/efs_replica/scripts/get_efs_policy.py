import sys
import json
import logging
import boto3
from botocore.exceptions import ClientError

# Test: python .\get_efs_policy.py '{\"file_system_id\": \"fs-009efb1ba6cd7857c\", \"aws_region\": \"us-east-1\", \"efs_name\": \"scenario1\"}'

try:
    input_str = sys.stdin.read()
    # use argv during testing
    #input_str = sys.argv[1]
    input_json = json.loads(input_str)
    efs_name = input_json.get("efs_name")
    file_system_id = input_json.get("file_system_id")
    aws_region = input_json.get("aws_region")

    client = boto3.client('efs', region_name=aws_region)

    #get EFS Policy
    response = client.describe_file_system_policy(FileSystemId=file_system_id)
    res_json = json.loads(response.get("Policy"))
    #print(res_json)

    #get EFS Access Points
    aps = client.describe_access_points(FileSystemId=file_system_id)
    ap_list = []
    for ap in aps["AccessPoints"] :
        #ap_list.append(f'{efs_name}-{ap["Name"]}')
        ap_list.append(ap["Name"])
    #print(ap_list)

    #Filter policy by APs
    policy = {}
    policy["Version"] = res_json["Version"]
    policy["Statement"] = []
    for stmt in res_json["Statement"] :
        sid = stmt.get("Sid", "NONE")
        for ap in ap_list :
            if sid == "NONE" or (sid.startswith("AllowAccessViaAP") and sid.endswith(ap)) :
                policy["Statement"].append(stmt)
    #print(policy)

    result = {
        "file_system_id": file_system_id,
        "policy": json.dumps(policy, indent=2), #response.get("Policy"),
        "error": ""
    }
except ClientError as e:
    result = {
        "file_system_id": file_system_id,
        "policy": "",
        "error": f'Error: {e}'
    }

print(json.dumps(result, indent=2))
