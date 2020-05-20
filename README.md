# TRAEFIK ON AWS EC2

[Traefik](https://containo.us/traefik/) setup to run all docker containers on AWS EC2 instances behind the same port 80 and 443 with automated LetsEncrypt certificates creation and renewal.

## AWS EC2 SETUP

To configure a EC2 instance with Traefik, Docker, Docker Compose and Git, just run the bash script in the root of this repo:

```
./aws-ec2-setup.sh
```

The end of the output will look like this:

```
---> DOCKER COMPOSE VERSION <---
docker-compose version 1.25.5, build 8a1c60f6


---> GIT VERSION<---
git version 2.23.3


---> TRAEFIK installed at: /opt/traefik <---

## Restart Traefik:
sudo docker-compose restart traefik

## Start Traefik:
sudo docker-compose up -d traefik

## Destroy Traefik:
sudo docker-compose down

## Tailing the Traefik logs in realtime:
docker-compose logs --follow traefik

---> TRAEFIK is now listening for new docker containers <---
```

This setup script will let Traefik running and listening for incoming requests on port `80` and `443`, where requests for port `80` will be redirected to port `443`.

## TLS CERTIFICATES

Traefik uses LetsEncrypt to automatically generated and renew TLS certificates for all domains is listening on.

## ADD A CONTAINER TO TRAEFIK

Traefik inspects the labels in all running docker containers to know for what ones needs to proxy requests.

Configure your `docker-compose.yml` service like:

```yml
services:

    api:
        ...

        labels:
            - "traefik.enable=true"

            # The public domain name for your docker container
            - "traefik.frontend.rule=Host:demo-name.approov.io"

            # Doesn't need to be exactly the same as the domain name.
            - "traefik.backend=demo-name.approov.io"

            # The external docker network that Traefik uses to proxy request to containers.
            - "traefik.docker.network=traefik"

            # This is the internal container port, not the public one.
            - "traefik.port=5000"
...

networks:
    ...

    traefik:
        external: true

```

With this configuration all requests for `https://demo-name.approov.io` will be proxy by Traefik to the docker container with the backend label `traefik.backend=demo-name.approov.io` on the internal container network port `traefik.port=5000`.
