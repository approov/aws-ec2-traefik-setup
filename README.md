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


## DEPLOY SERVER EXAMPLE

Let's see an example of deploying Python Shapes API backend into the `demo.approov.io`.

#### Create the folder

```
mkdir -p ~/backend && cd ~/backend
```

#### Clone the repo

```
git clone --branch dev-deployment https://github.com/approov/python-flask_approov-shapes-api-server && cd python-flask_approov-shapes-api-server
```

#### Create the .env file

```
cp .env.example .env
```

#### Edit the .env file

Replace the default domain with your own server domain:

```bash
PYTHON_FLASK_SHAPES_DOMAIN=your.domain.com
```

Replace the dummy Approov secret on it with the one for your Approov account:

```bash
# approov secret -get base64
APPROOV_BASE64_SECRET=your-secret-here
```

#### Start the Docker Stack

```
sudo docker-compose up -d
```

Now in your browser visit `your.domain.com` to check the server is accepting requests.

#### Tail the logs

```
sudo docker-compose logs -f
```

## ADD A CONTAINER TO TRAEFIK

Traefik inspects the labels in all running docker containers to know for what ones needs to proxy requests.

So if your backend does not have yet support for Traefik in the `docker-compose.yml` file you can configure your service like this:

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
