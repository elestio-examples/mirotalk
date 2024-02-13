<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# Mirotalk, verified and packaged by Elestio

[Mirotalk](https://github.com/miroslavpejic85/mirotalk) is Free WebRTC - P2P - Simple, Secure, Fast Real-Time Video Conferences with support for up to 4k resolution and 60fps. It's compatible with all major browsers and platforms.

<img src="https://raw.githubusercontent.com/elestio-examples/mirotalk/main/mirotalk.png" alt="mirotalk" width="800">

[![deploy](https://github.com/elestio-examples/mirotalk/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/mirotalk)

Deploy a <a target="_blank" href="https://elest.io/open-source/mirotalk">fully managed mirotalk</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want automated backups, reverse proxy with SSL termination, firewall, automated OS & Software updates, and a team of Linux experts and open source enthusiasts to ensure your services are always safe, and functional.

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/mirotalk.git

Copy the .env files from tests folder to the project directory

    cp ./tests/webrtc/.env ./.env
    cp ./tests/webrtc/bro.env ./bro.env
    cp ./tests/webrtc/c2c.env ./c2c.env
    cp ./tests/webrtc/p2p.env ./p2p.env

Edit the .env files with your own values.

Copy the config.js and sfu.js files from tests folder to the project directory

    cp ./tests/webrtc/config.js ./config.js
    cp ./tests/webrtc/sfu.js ./sfu.js

Edit them with your own values.

Run the project with the following command

    docker-compose up -d
    ./scripts/postInstall.sh

You can access the Web UI at: `http://your-domain:26645`

## Docker-compose

Here are some example snippets to help you get started creating a container.

        version: "3"

        services:
        mirotalkwebrtc:
            image: elestio/mirotalk:${SOFTWARE_VERSION_TAG}
            restart: always
            hostname: mirotalkwebrtc
            volumes:
                - .env:/src/.env:ro
                - ./configs/config.js:/src/backend/config.js:ro
                # - ./backend/:/src/backend/:ro
                # - ./frontend/:/src/frontend/:ro
            ports:
                - "172.17.0.1:26645:${SERVER_PORT}"
            links:
                - mongodb

        mongodb:
            image: mongo:latest
            restart: always
            environment:
            MONGO_INITDB_ROOT_USERNAME: ${MONGO_USERNAME}
            MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
            MONGO_INITDB_DATABASE: ${MONGO_DATABASE}
            ports:
                - "172.17.0.1:${MONGO_PORT}:${MONGO_PORT}"
            volumes:
                - "./.mongodb_data:/data/db"
            command: mongod --quiet --logpath /dev/null

        mirotalksfu:
            image: mirotalk/sfu:latest
            restart: always
            volumes:
                - ./configs/sfu.js:/src/app/src/config.js:ro
                # These volumes are not mandatory, comment if you want to use it
                # - ./app/:/src/app/:ro
                # - ./public/:/src/public/:ro
            ports:
                - "172.17.0.1:3010:3010/tcp"
                - "40000-40100:40000-40100/tcp"
                - "40000-40100:40000-40100/udp"

        mirotalkc2c:
            image: mirotalk/c2c:latest
            volumes:
                - ./c2c.env:/src/.env:ro
                # These volumes are not mandatory, uncomment if you want to use it
                # - ./frontend/:/src/frontend/:ro
                # - ./backend/:/src/backend/:ro
            restart: always
            ports:
                - "172.17.0.1:36703:8080"

        mirotalkbro:
            image: mirotalk/bro:latest
            volumes:
                - ./bro.env:/src/.env:ro
                # These volumes are not mandatory, uncomment if you want to use it
                # - ./app/:/src/app/:ro
                # - ./public/:/src/public/:ro
            restart: always
            ports:
                - "172.17.0.1:21208:3016"

        mirotalkp2p:
            image: mirotalk/p2p:latest
            volumes:
                - ./p2p.env:/src/.env:ro
                # These volumes are not mandatory, uncomment if you want to use it
                # - ./app/:/src/app/:ro
                # - ./public/:/src/public/:ro
            restart: always
            ports:
                - "172.17.0.1:43850:3000"

### Environment variables

|        Variable        |               Value (example)                |
| :--------------------: | :------------------------------------------: |
|      SERVER_HOST       |                 your_domain                  |
|      ADMIN_EMAIL       |                your@email.com                |
|     ADMIN_PASSWORD     |                your-password                 |
|      SERVER_PORT       |                     9000                     |
|       SERVER_URL       |             https://your_domain              |
|        JWT_KEY         |                   your_key                   |
|        JWT_EXP         |                      2h                      |
|       MONGO_HOST       |                   mongodb                    |
|     MONGO_USERNAME     |                     root                     |
|     MONGO_PASSWORD     |                your-password                 |
|     MONGO_DATABASE     |                   mirotalk                   |
|       MONGO_PORT       |                    27017                     |
|       MONGO_URL        | mongodb://root:[your_password]@mongodb:27017 |
|   EMAIL_VERIFICATION   |                     true                     |
|     ADMIN_USERNAME     |                   USERNAME                   |
|     NGROK_ENABLED      |                    false                     |
|       TWILIO_SMS       |                    false                     |
| USER_REGISTRATION_MODE |                     true                     |
|           IP           |                51.15.194.244                 |
|       EMAIL_HOST       |               your.email.host                |
|       EMAIL_PORT       |               your.email.port                |
|     EMAIL_USERNAME     |                your@email.com                |
|     EMAIL_PASSWORD     |             your-email-password              |

# Maintenance

## Logging

The Elestio Mirotalk Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/miroslavpejic85/mirotalk">Mirotalk documentation</a>

- <a target="_blank" href="https://docs.mirotalk.com/">Mirotalk Github repository</a>

- <a target="_blank" href="https://github.com/elestio-examples/mirotalk">Elestio/mirotalk Github repository</a>
