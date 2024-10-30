#!/bin/bash 

sudo apt-get update -yy
sudo apt-get install -yy git curl 

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

git clone https://github.com/FayAlaamri/capstone-project.git
cd capstone-project
echo "REDIS_HOST=${redis}" > .env
echo "DB_HOST=${db}" >> .env
echo "DB_PASSWORD=password" >> .env
echo "DB_USER=user" >> .env
echo "DB_NAME=mydatabase" >> .env
docker pull fayalaamri/flask
docker run -p 80:5000 --env-file .env --name app fayalaamri/flask