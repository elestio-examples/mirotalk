#!/usr/bin/env bash

docker buildx build . --output type=docker,name=elestio4test/mirotalk-c2c:latest | docker load