import json
import urllib.request
import urllib.error

url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAIjwg1Ufsv0E7ZUdfh1Ug_jcs1_wR557A'
body = json.dumps({
    'email': 'test-not-exist@example.com',
    'password': 'invalidpassword',
    'returnSecureToken': True,
}).encode('utf-8')
req = urllib.request.Request(url, data=body, headers={'Content-Type': 'application/json'})
try:
    resp = urllib.request.urlopen(req)
    print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print('HTTP', e.code)
    print(e.read().decode('utf-8'))
