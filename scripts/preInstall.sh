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

COTURN_PASSWORD=${COTURN_PASSWORD:-`openssl rand -hex 8`}



sed -i -e "s~IP_TO_CHANGE~${IP}~g" ./configs/sfu.js
sed -i -e "s~HOST_TO_CHANGE~${SERVER_HOST}~g" ./configs/config.js

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
STUN_SERVER_URL=stun:${SERVER_HOST}:3478

TURN_SERVER_ENABLED=true # true or false
TURN_SERVER_URL=turn:${SERVER_HOST}:3478
TURN_SERVER_USERNAME=miro_user
TURN_SERVER_CREDENTIAL=${COTURN_PASSWORD}

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
STUN_SERVER_URL=stun:${SERVER_HOST}:3478

TURN_SERVER_ENABLED=true # true or false
TURN_SERVER_URL=turn:${SERVER_HOST}:3478
TURN_SERVER_USERNAME=miro_user
TURN_SERVER_CREDENTIAL=${COTURN_PASSWORD}

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


cat << EOT >> ./p2p.env
# Enable self-signed certs (app/ssl)

HTTPS=false # true or false

# Domain

HOST=mirotalkgjhj-u353.vm.elestio.app

# IP whitelist
# Access to the instance is restricted to only the specified IP addresses in the allowed list. This feature is disabled by default.

IP_WHITELIST_ENABLED=false # true or false

IP_WHITELIST_ALLOWED='["127.0.0.1", "::1"]'

# Host protection
# HOST_PROTECTED: When set to true, it requires a valid username and password from the HOST_USERS list to initialize or join a room.
# HOST_USER_AUTH: When set to true, it also requires a valid username and password for joining the room.
# HOST_USERS: This is the list of valid host users along with their credentials.

HOST_PROTECTED=false # true or false

HOST_USER_AUTH=false # true or false

HOST_USERS='[{"username": "username", "password": "password"},{"username": "username2", "password": "password2"}]'

# Presenters list
# In our virtual room, the first participant to join will assume the role of the presenter. 
# Additionally, we have the option to include more presenters and co-presenters, each identified by their username.

PRESENTERS='["Miroslav Pejic", "miroslav.pejic.85@gmail.com"]'

# Signaling Server listen port

PORT=3000

# Ngrok
# 1. Goto https://ngrok.com
# 2. Get started for free 
# 3. Copy YourNgrokAuthToken: https://dashboard.ngrok.com/get-started/your-authtoken

NGROK_ENABLED=false # true or false
NGROK_AUTH_TOKEN=YourNgrokAuthToken

# Stun
# About: https://bloggeek.me/webrtcglossary/stun/
# Check: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

STUN_SERVER_ENABLED=true # true or false
STUN_SERVER_URL=stun:${SERVER_HOST}:3478

# Turn 
# About: https://bloggeek.me/webrtcglossary/turn/
# Recommended: https://github.com/coturn/coturn
# Installation: https://github.com/miroslavpejic85/mirotalk/blob/master/docs/coturn.md
# Free one: https://www.metered.ca/tools/openrelay/ (Please, create your own account)
# Check: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

TURN_SERVER_ENABLED=true # true or false
TURN_SERVER_URL=turn:${SERVER_HOST}:3478
TURN_SERVER_USERNAME=miro_user
TURN_SERVER_CREDENTIAL=${COTURN_PASSWORD}

# IP lookup
# Using GeoJS to get more info about peer by IP
# Doc: https://www.geojs.io/docs/v1/endpoints/geo/

IP_LOOKUP_ENABLED=false # true or false

# API
# The response will give you a entrypoint / Room URL for your meeting.
# curl -X POST "http://localhost:3000/api/v1/meeting" -H  "authorization: mirotalk_default_secret" -H  "Content-Type: application/json"

API_KEY_SECRET=mirotalk_default_secret

# Survey URL 
# Using to redirect the client after close the call (feedbacks, website...)

SURVEY_ENABLED=true # true or false
SURVEY_URL=https://www.questionpro.com/t/AUs7VZq00L

# Redirect URL on leave room
# Upon leaving the room, users who either opt out of providing feedback or if the survey is disabled 
# will be redirected to a specified URL. If enabled false the default '/newrcall' URL will be used.

REDIRECT_ENABLED=false # true or false
REDIRECT_URL='https://p2p.mirotalk.com'

# Sentry (optional)
# 1. Goto https://sentry.io/
# 2. Create account
# 3. Goto Settings/Projects/YourProjectName/Client Keys (DSN)

SENTRY_ENABLED=false # true or false
SENTRY_DSN=YourClientKeyDSN
SENTRY_TRACES_SAMPLE_RATE=1.0

# Slack Integration (optional)
# 1. Goto https://api.slack.com/apps/
# 2. Create your app
# 3. On Settings - Basic Information - App Credentials chose your Signing Secret
# 4. Create a Slash Commands and put as Request URL: https://your.domain.name/slack

SLACK_ENABLED=false # true or false
SLACK_SIGNING_SECRET=YourSlackSigningSecret

# ChatGPT/OpenAI
# 1. Goto https://platform.openai.com/
# 2. Create your account
# 3. Generate your APIKey https://platform.openai.com/account/api-keys

CHATGPT_ENABLED=false
CHATGPT_BASE_PATH=https://api.openai.com/v1/
CHATGTP_APIKEY=YourOpenAiApiKey
CHATGPT_MODEL=gpt-3.5-turbo-instruct
CHATGPT_MAX_TOKENS=1000
CHATGPT_TEMPERATURE=0

# Stats
# Umami: https://github.com/umami-software/umami
# We use our Self-hosted Umami to track aggregated usage statistics in order to improve our service.

STATS_ENABLED=true # true or false
STATS_SCR=https://stats.mirotalk.com/script.js
STATS_ID=c7615aa7-ceec-464a-baba-54cb605d7261

EOT


cat << EOT >> ./turnserver.conf
listening-port=3478
# tls-listening-port=5349

min-port=10000
max-port=20000

fingerprint
lt-cred-mech

user=miro_user:${COTURN_PASSWORD}

server-name=${SERVER_HOST}
realm=${SERVER_HOST}

total-quota=100
stale-nonce=600


no-stdout-log

EOT
