from datetime import datetime
import json
import requests

from ec2_metadata import ec2_metadata
import boto3
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

JUPYTER_PORT = '8443'
IDLE_TIME = 2400

def get_uptime():
	with open('/proc/uptime', 'r') as f:
			uptime_seconds = float(f.readline().split()[0])

	return uptime_seconds

def is_jupyter_lab_idle():
	try:
		response = requests.get('http://localhost:'+JUPYTER_PORT+'/api/sessions', verify=False)
		data = response.json()
		if len(data) > 0:
			for notebook in data:
				if notebook['kernel']['execution_state'] != 'idle':
					return False

				if not is_notebook_idle(notebook['kernel']['last_activity']):
					return False
	except:
		pass

	return True


def is_notebook_idle(last_activity):
	last_activity = datetime.strptime(last_activity,"%Y-%m-%dT%H:%M:%S.%fz")

	if (datetime.now() - last_activity).total_seconds() > IDLE_TIME:
		return True

	return False


def run():
	if get_uptime() <= IDLE_TIME:
		return

	if is_jupyter_lab_idle():
		session = boto3.session.Session(region_name=ec2_metadata.region)
		ec2 = session.resource('ec2')
		instance = ec2.Instance(ec2_metadata.instance_id)
		instance.stop()


run()
