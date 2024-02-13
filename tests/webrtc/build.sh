#!/usr/bin/env bash
cp backend/config.template.js backend/config.js
docker buildx build . --output type=docker,name=elestio4test/mirotalk-webrtc:latest | docker load