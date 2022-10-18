# WireGuard installation and configuration - in Docker
In this tutorial, I will show you how to easily create your own private VPN server with WireGuard running in a Docker container. I will walk you step by step through the installation, configuration, and how to add clients to your VPN server.

We will use the free and open-source VPN protocol WireGuard

Project Homepage: https://www.wireguard.com/

Video: https://youtu.be/GZRTnP4lyuo

## Prerequisites

- Linux Server running Ubuntu 20.04 LTS or newer

*For installing Docker on other Linux distriubtions or different versions than Ubuntu 20.04 LTS, follow the [official installation instructions](https://docs.docker.com/install/).*

## Install Docker, and Docker-Compose

You can still install Docker on a Linux Server that is not running Ubuntu, however, this may require different commands!

### Install Docker
```bash
sudo apt update

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

sudo apt-get install docker-ce docker-ce-cli containerd.io
```

### Check if Docker is installed correctly
```bash
sudo docker run hello-world
```

### Install Docker-Compose

Download the latest version (in this case it is 1.25.5, this may change whenever you read this tutorial!)

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### Check if Docker-Compose is installed correctly
```bash
sudo docker-compose --version
```

### (Optional) Add your linux user to the `docker` group
```bash
sudo usermod -aG docker $USER
```

## Set up Wireguard in Docker

### Create a new Docker-Compose file

Create a new folder in the `/opt` directory.

You can also use your personal home folder `/home/<your-username>`, this may require different permissions.

Create a new file `docker-compose.yml`file, please refer to the linuxserver/wireguard documentation: https://hub.docker.com/r/linuxserver/wireguard.

Replace the `<your-server-url>` with the public IP address of your WireGuard Server, because your clients will need to connect from outside your local network. You can also set this to auto, the docker container will automatically determine your public IP address and use this in the client's configuration.

```yml
version: "2.1"
services:
  wireguard:
    image: linuxserver/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - SERVERURL=<your-server-url> #optional
      - SERVERPORT=51820 #optional
      - PEERS=1 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
    volumes:
      - /opt/wireguard-server/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

### Start the WireGuard Server
```bash
docker-compose up -d
```

### Distribute the config files to clients

You could also use the docker image for your clients. But I think it's more practical for a client to install WireGuard directly on the host OS. If you want to know how to do that, you can also refer to my article about WireGuard installation and configuration on Linux.

When you have started the WireGuard container, it should automatically create all configuration files in your `./config` folder. All you need to do is to copy the corresponding `./config/peer1/peer1.conf` file to your client and use that as your `wg0.conf`, for instance. If you want to connect mobile phones you can also just scan the peer1.png QR code, to print the QR code to the console, simply use the following command:

```bash
docker exec -it wireguard /app/show-peer <peer-number>
```

### (Optional) Add additional clients

If you want to add additional clients, you simply can increase the PEERS parameter in the docker-compose.yaml file. After changing this value you need to restart your docker container with the `--force-recreate` parameter.

```bash
docker-compose up -d --force-recreate
```
