#!/usr/bin/env bash

docker buildx build . --output type=docker,name=elestio4test/mirotalk-p2p:latest | docker load