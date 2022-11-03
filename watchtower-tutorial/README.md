# How To Update Docker Container automatically with nearly zero downtime
How to update docker container automatically with Watchtower. Scheduled updates without downtime for your entire docker environment.

We will use the free and open-source software Watchtower.

Project Homepage: https://containrrr.dev/watchtower/

Video: https://youtu.be/5lP_pdjcVMo

## Prerequisites

- Linux Server running Docker

## Run Watchtower

Watchtower can be easily deployed by executing a simple docker run command.

```bash
docker run --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
```

## Run Watchtower in debug mode

You might wonder why there is no log output apart from the welcome message. If you want to increase the logging level or watchtower, you simply just add an argument.

```bash
docker run --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --debug
```

## Run Watchtower only once, in debug mode

```bash
docker run --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --debug
```

## Exclude Container from Watchtower

```bash
docker run -d --label=com.centurylinklabs.watchtower.enable= false nginx
```

## Scheduled Updates and clean up old images

```bash
docker run --name watchtower -v /var/run/docker.sock:/var/run/docker.sock --restart unless-stopped containrrr/watchtower --schedule "0 0 4 * * *" --debug --cleanup
```
