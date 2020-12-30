#!/bin/bash


# parse Skript Argumente
while getopts ":s:d:b:f:w:" opt; do 
    case $opt in
        s)
            stop_flag=true
        d)
            delete_flag=true
            stop_flag=true
        b) 
            backend_flag=true
            ;;
        f) 
            frontend_flag=true
            ;;
        w)
            watch_flag=true
            ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done


# Stoppe Container
if [ "$stop_flag" = true ]; then
    # Stoppe "evidence-*" container
    docker ps | grep evidence- | xargs -L1 docker stop
fi


# Lösche Container und Images (Tabula Rasa)
if [ "$delete_flag" = true ]; then
    # delete "evidence-*" container
    docker rm -vf $(docker ps -a --no-trunc --filter="name=evidence-" -q)
    # delete "evidence-* images
    docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' | grep evidence-)
    # delete networks
    docker network rm evidence-backend-network
    docker network rm evidence-frontend-network
    # tidy up dangling images (general housekeeping)
    docker rmi $(docker images -f "dangling=true" -q)
fi


# Backend Container
if [ "$backend_flag" = true ]; then
    # Erzeuge Docker Network
    if [[ $(docker network ls | grep "evidence-backend-network" | wc -l) -eq 0 ]];
    then
        docker network create --driver bridge \
            --subnet=172.20.253.0/28 \
            --ip-range=172.20.253.8/29 \
            evidence-backend-network
    fi

    # Starte Backend Container
    folders=(database restapi)
    for folder in ${folders[@]}; do
        nohup docker-compose \
            -f "./${folder}/docker-compose.yml" \
            up --build >/dev/null 2>&1 &
    done
fi


# Frontend Container
if [ "$frontend_flag" = true ]; then
    # Erzeuge Docker Network
    if [[ $(docker network ls | grep "evidence-backend-network" | wc -l) -eq 0 ]];
    then
        docker network create --driver bridge \
            --subnet=172.20.253.16/29 \
            --ip-range=172.20.253.20/30 \
            evidence-frontend-network
    fi

    # Starte Frontend Container
    folders=(webapp)
    for folder in ${folders[@]}; do
        nohup docker-compose \
            -f "./${folder}/docker-compose.yml" \
            up --build >/dev/null 2>&1 &
    done
fi


# Beobachte Container Status [debugging mode]
if [ "$watch_flag" = true ]; then
    # message
    echo "Hit [Ctrl+C] to stop containers."

    # check status
    watch docker ps
fi

