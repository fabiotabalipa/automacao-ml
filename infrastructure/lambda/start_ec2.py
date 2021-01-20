import json
import os
import time

import boto3


def lambda_handler(event, context):
		session = boto3.session.Session(region_name=os.getenv('EC2_REGION'))
		ec2 = session.resource('ec2')
		instance = ec2.Instance(os.getenv('EC2_INSTANCE_ID'))
		
		resDict = {
			'headers': {
				'content-type': 'application/json; charset=utf-8'
			},
			'statusCode': 200
		}
		if instance.state['Name'] == 'running':
			resDict['body'] = json.dumps({
				'message': 'Jupyter Lab already running at http://{}:8443/lab. Remember: it will be inactive again when idle for 40 min.'.format(instance.public_dns_name)
			})
			return resDict
		
		instance.start()
		resDict['body'] = json.dumps({
			'message': 'Jupyter Lab will start in 1-3 min. Wait and reload this request to get the access URL.'.format(instance.public_dns_name)
		})
		return resDict
