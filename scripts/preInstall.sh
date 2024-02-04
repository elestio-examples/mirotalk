#set env vars
set -o allexport; source .env; set +o allexport;

cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"

done < "$filename"

cat << EOT >> ./.env

EMAIL_HOST=tuesday.mxrouting.net
EMAIL_PORT=25
EMAIL_USERNAME=${SMTP_LOGIN}
EMAIL_PASSWORD=${SMTP_PASSWORD}
EOT

rm post.txt



sed -i -e "s~IP_TO_CHANGE~${IP}~g" ./configs/sfu.js
sed -i -e "s~HOST_TO_CHANGE~${SERVER_HOST}~g" ./configs/sfu.js

cat << EOT >> ./bro.env
# Server

PROTOCOL=http # http or https
HOST=${SERVER_HOST}
PORT=3016

# Logs

DEBUG=true # true or false

# Stun: https://bloggeek.me/webrtcglossary/stun/
# Turn: https://bloggeek.me/webrtcglossary/turn/
# Recommended: https://github.com/coturn/coturn
# Installation: https://github.com/miroslavpejic85/mirotalkbro/blob/main/docs/coturn.md
# Free one: https://www.metered.ca/tools/openrelay/ (Please, create your own account)
# Check: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

STUN_SERVER_ENABLED=true # true or false
STUN_SERVER_URL=stun:stun.l.google.com:19302

TURN_SERVER_ENABLED=true # true or false
TURN_SERVER_URL=turn:a.relay.metered.ca:443
TURN_SERVER_USERNAME=e8dd65b92c62d3e36cafb807
TURN_SERVER_CREDENTIAL=uWdWNmkhvyqTEswO

# API
# The response will give you a entrypoint / URL for the direct join to the meeting.
# curl -X POST "http://localhost:3016/api/v1/join" -H "authorization: mirotalkbro_default_secret" -H "Content-Type: application/json" --data '{"room":"test"}'

API_KEY_SECRET=mirotalkbro_default_secret

# Ngrok
# 1. Goto https://ngrok.com
# 2. Get started for free
# 3. Copy YourNgrokAuthToken: https://dashboard.ngrok.com/get-started/your-authtoken

NGROK_ENABLED=false # true or false
NGROK_AUTH_TOKEN=YourNgrokAuthToken

# Sentry
# 1. Goto https://sentry.io/
# 2. Create account
# 3. Goto Settings/Projects/YourProjectName/Client Keys (DSN)

SENTRY_ENABLED=false # true or false
SENTRY_DSN=YourClientKeyDSN
SENTRY_TRACES_SAMPLE_RATE=0.5
EOT

cat << EOT >> ./c2c.env
HTTPS=false
HOST=${SERVER_HOST}
PORT=8080

# Stun - https://bloggeek.me/webrtcglossary/stun/
# Turn - https://bloggeek.me/webrtcglossary/turn/
# Recommended: https://github.com/coturn/coturn
# Installation: https://github.com/miroslavpejic85/mirotalkc2c/blob/main/docs/coturn.md
# Free one: https://www.metered.ca/tools/openrelay/ (Please, create your own account)
# Check: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

STUN_SERVER_ENABLED=true # true or false
STUN_SERVER_URL=stun:stun.l.google.com:19302

TURN_SERVER_ENABLED=true # true or false
TURN_SERVER_URL=turn:a.relay.metered.ca:443
TURN_SERVER_USERNAME=e8dd65b92c62d3e36cafb807
TURN_SERVER_CREDENTIAL=uWdWNmkhvyqTEswO

# API
# The response will give you a entrypoint / Room URL for your meeting.
# curl -X POST "http://localhost:8080/api/v1/meeting" -H  "authorization: mirotalkc2c_default_secret" -H  "Content-Type: application/json"
# The response will give you a entrypoint / URL for the direct join to the meeting.
# curl -X POST "http://localhost:8080/api/v1/join" -H "authorization: mirotalkc2c_default_secret" -H "Content-Type: application/json" --data '{"room":"test","name":"mirotalkc2c"}'

API_KEY_SECRET=mirotalkc2c_default_secret

# Ngrok
# 1. Goto https://ngrok.com
# 2. Get started for free 
# 3. Copy YourNgrokAuthToken: https://dashboard.ngrok.com/get-started/your-authtoken

NGROK_ENABLED=false # true or false
NGROK_AUTH_TOKEN=YourNgrokAuthToken

# Survey and Redirect on leave room URL

SURVEY_URL=https://questionpro.com/t/AUs7VZwgxI
REDIRECT_URL= #https://c2c.mirotalk.com
EOT