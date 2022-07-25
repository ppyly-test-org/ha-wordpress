import base64
import requests
import os
import json
from requests.exceptions import Timeout

streak_dict = dict()



def hello_pubsub(event, context, print=None):
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)

    endpoints = os.environ.get('endpoints', False)

    if not endpoints:
        print('No endpoints are setted')
        return
    endpoints = endpoints.split(', ')

    for endpoint in endpoints:
        try:
            status = get_request(endpoint)
            health = is_healthy(status)
            message = "Endpoint {0}, responce with status {1}. Healthcheck {2}".format(endpoint, status, health)
            severity = "DEFAULT" if health else "WARNING"
            log(message, severity)
            gacha(endpoint, health)
        except Timeout:
            message = "Endpoint {0} connection timeot or site is unreachable".format(endpoint)
            log(message, "ERROR")


def gacha(endpoint, health):
    if health:
        streak_dict[endpoint] = 0
    else:
        value = streak_dict.get(endpoint)
        if value is not None:
            streak_dict[endpoint] += 1
        else:
            streak_dict[endpoint] = 1
    if streak_dict[endpoint] >= 3:
        message = "Endpoint {0}, failed healthcheck 3 or more times .".format(endpoint)
        log(message, "ALERT")


def get_request(endpoint):
    r = requests.get(endpoint, verify=False,timeout=5)
    return r.status_code


def is_healthy(status_code):
    if status_code >= 200 and status_code < 400:
        return True
    elif status_code >= 400 and status_code < 600:
        return False
    else:
        return None
def log(message, severity):
    PROJECT = 'gcp101588-educoeppyly'
    entry = dict(
        severity=severity,
        message=message,
        component="arbitrary-property",
    )

    print(json.dumps(entry))