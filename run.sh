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
    # tidy up dangling images (general housekeeping)
    docker rmi $(docker images -f "dangling=true" -q)
fi


# Backend Container
if [ "$backend_flag" = true ]; then
    # Erzeuge Docker Network

    # Starte Backend Container
    folders=(database restapi)
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

