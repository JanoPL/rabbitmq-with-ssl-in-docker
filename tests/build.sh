#!/bin/bash

IMAGE_NAME="rabbitmq-with-ssl"

docker build --build-arg var_domain=${IMAGE_NAME} --no-cache=true -t ${IMAGE_NAME} ..
