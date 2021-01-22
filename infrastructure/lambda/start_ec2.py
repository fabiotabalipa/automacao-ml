import json
import os
import time

import boto3

def res(code, msg):
	return {
		'headers': {
			'content-type': 'application/json; charset=utf-8'
		},
		'statusCode': code,
		'body': json.dumps({
			'message': msg
		})
	}

def lambda_handler(event, context):
		malformed_err_msg = 'URL must contain a "pass" query string!'
		if 'queryStringParameters' not in event.keys():
			return res(400, malformed_err_msg)
		
		if event['queryStringParameters'] is None:
			return res(400, malformed_err_msg)

		if 'pass' not in event['queryStringParameters'].keys():
			return res(400, malformed_err_msg)
		
		if event['queryStringParameters']['pass'] != os.getenv('TEAM_PASS'):
			return res(403, 'Wrong password.')
		
		session = boto3.session.Session(region_name=os.getenv('EC2_REGION'))
		ec2 = session.resource('ec2')
		instance = ec2.Instance(os.getenv('EC2_INSTANCE_ID'))
		
		if instance.state['Name'] == 'running':
			return res(200, 'Jupyter Lab already running at http://{}:8443/lab. Remember: it will be inactive again when idle for 40 min.'.format(instance.public_dns_name))
		
		instance.start()
		return res(200, 'Jupyter Lab will start in 1-3 min. Wait and reload this request to get the access URL.'.format(instance.public_dns_name))
