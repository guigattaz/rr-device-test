"""usage: send.py <subscription.json> [title] [body]  -> sends one real Web Push to the iPhone test page"""
import json, os, sys
from pywebpush import webpush, WebPushException
sub = json.load(open(sys.argv[1]))
title = sys.argv[2] if len(sys.argv) > 2 else 'New neighbor: Mike R.'
body = sys.argv[3] if len(sys.argv) > 3 else 'Dana sent you a neighbor. Call today. (real push test)'
try:
    r = webpush(sub, json.dumps({'title': title, 'body': body}), vapid_private_key=os.path.expanduser('~/.config/rr-device-test/private.pem')   # private key never in the repo,
                vapid_claims={'sub': 'mailto:noreply@routereferrals.com'}, ttl=600)
    print('sent', r.status_code)
except WebPushException as e:
    print('failed', e.response.status_code if e.response is not None else '', e)
