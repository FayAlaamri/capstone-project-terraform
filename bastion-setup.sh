#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl git

mkdir actions-runner && cd actions-runner

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
