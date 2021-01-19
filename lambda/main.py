import json
import os

import boto3


def lambda_handler(event, context):
    client = boto3.client('sagemaker')
    client.start_notebook_instance(NotebookInstanceName=os.getenv('SAGEMAKER_INSTANCE_NAME'))

    return {
        'statusCode': 200,
        'body': json.dumps('Ok. A instancia esta acordando... Aguarde cerca de 3 min e acesse a URL: https://{}/lab. Lembre-se: ela adormecera novamente apos 40 min de inatividade.'.format(os.getenv('SAGEMAKER_URL')))
    }
