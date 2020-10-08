#!/bin/bash

# start all containers
folders=(database restapi webapp)
for folder in ${folders[@]}; do
    nohup docker-compose -f "./${folder}/docker-compose.yml"  up --build >/dev/null 2>&1 &
done

# message
echo "Hit [Ctrl+C] to stop containers."

# check status
watch docker ps



# DOESN'T WORK. TO MANY CONFLICT. Doesn't matter
# Merge all YML files
# docker-compose \
#     -f ./restapi/docker-compose.yml \
#     -f ./database/docker-compose.yml \
#     up --build
