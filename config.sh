#!/bin/bash

# Docker
declare CONJUR_DEPLOY_TAG=conjur
declare CONJUR_DOCKER_IMAGE=conjur-appliance:4.9-stable

# For the host conjur cli
declare CONJUR_CERT_PATH="./conjur-${CONJUR_ACCOUNT}.pem"
declare CONJURRC="./conjurrc"
export CONJURRC
