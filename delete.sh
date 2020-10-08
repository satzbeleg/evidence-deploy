#!/bin/bash

# stop "evidence" container
docker ps | grep evidence- | xargs -L1 docker stop

# delete "evidence" container
docker rm -vf $(docker ps -a --no-trunc --filter="name=evidence" -q)

# delete "evidence" images
docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' | grep evidence-)


# tidy up dangling images (general housekeeping)
docker rmi $(docker images -f "dangling=true" -q)
