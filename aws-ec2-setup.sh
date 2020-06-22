#!/bin/sh

set -eu

Setup_Depedencies() {
    printf "\n---> INSTALL DEPENDENCIES <---\n"
    sudo yum update -y
    sudo yum install -y git curl
}

Setup_Docker() {
    printf "\n---> INSTALL DOCKER <---\n"
    sudo amazon-linux-extras install -y docker
    sudo service docker start
}

Setup_Docker_Compose() {
    printf "\n---> INSTALL DOCKER COMPOSE <---\n"
    local _download_url="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
    sudo curl -L "${_download_url}" -o /usr/bin/docker-compose
    sudo chmod ug+x /usr/bin/docker-compose
}

Setup_Traefik() {
    printf "\n---> INSTALL TRAEFIK <---\n"

    sudo cp -r ./traefik /opt

    cd /opt/traefik

    # Traefik will not create the certificates if we don't fix the permissions
    #  for the file where it stores the LetsEncrypt certificates.
    sudo chmod 600 acme.json

    # Creates a docker network that will be used by Traefik to proxy the requests to the docker containers:
    sudo docker network create traefik || true

    sudo cp .env.example .env

    # Traefik will be listening on port 80 and 443, and proxy the requests to
    #  the associated container for the domain. Check the README for more details.
    sudo docker-compose up -d traefik

    # Just give sometime for it to start in order to check the logs afterwards.
    sleep 5

    printf "\n---> CHECK TRAEFIK LOGS <---\n"
    sudo docker-compose logs traefik

    cd -
}

Main() {
    Setup_Depedencies
    Setup_Docker
    Setup_Docker_Compose
    Setup_Traefik

    printf "\n\n---> DOCKER VERSION <---\n"
    sudo docker version

    printf "\n---> DOCKER COMPOSE VERSION <---\n"
    sudo docker-compose --version
    echo

    printf "\n---> GIT VERSION<---\n"
    git version
    echo

    printf "\n---> TRAEFIK installed at: /opt/traefik <---\n"

    printf "\n## Restart Traefik:\n"
    printf "sudo docker-compose restart traefik\n"

    printf "\n## Start Traefik:\n"
    printf "sudo docker-compose up -d traefik\n"

    printf "\n## Destroy Traefik:\n"
    printf "sudo docker-compose down\n"

    printf "\n## Tailing the Traefik logs in realtime:"
    printf "\ndocker-compose logs --follow traefik\n"

    printf "\n---> TRAEFIK is now listening for new docker containers <---\n\n"
}

Main ${@}
