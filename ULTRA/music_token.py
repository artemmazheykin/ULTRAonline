# requires pyjwt (https://pyjwt.readthedocs.io/en/latest/)
# pip install pyjwt


import datetime
import jwt

secret = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg5WOHny5xRjR8HW7iK1WgoFe7sny9DR/j2jFDLjS+O4ugCgYIKoZIzj0DAQehRANCAAStrCj6UcXwAhRQkQ5XTpBO5rem4+NT+seB5YVOaN/gnpoVybZZBmV130Er+iJDGasq8qwOQO0AJ4d+
KqfxINwc
-----END PRIVATE KEY-----"""
keyId = "L354WH5U33"
teamId = "77324NTG3D"
alg = 'ES256'

time_now = datetime.datetime.now()
time_expired = datetime.datetime.now() + datetime.timedelta(hours=12)

headers = {
    "alg": alg,
    "kid": keyId
}

payload = {
    "iss": teamId,
    "exp": int(time_expired.strftime("%s")),
    "iat": int(time_now.strftime("%s"))
}


if __name__ == "__main__":
    """Create an auth token"""
    token = jwt.encode(payload, secret, algorithm=alg, headers=headers)
    
    print "----TOKEN----"
    print token
    
    print "----CURL----"
    print "curl -v -H 'Authorization: Bearer %s' \"https://api.music.apple.com/v1/catalog/us/artists/36954\" " % (token)

