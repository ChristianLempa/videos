# Manage all your SSH servers with teleport
How to set up an SSH proxy server with gravitational teleport to manage all your SSH connections from a web interface. Supports 2FA two-factor authentication, multiple users, monitoring, and logging of SSH sessions. Install on DigitalOcean Cloud and manage via letsencrypt load balancer certs.

We will use the free and open-source software Teleport.


Project Homepage: https://goteleport.com/
Documentation: https://goteleport.com/docs/

Video: https://youtu.be/nk1jfIAL5qE

## Prerequisites

- Linux Server running Ubuntu 20.04 LTS or newer
- Domain that points to the public IP of your Linux Server

You can still install Docker on a Linux Server that is not running Ubuntu, however, this may require different commands!

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

## Set up Teleport

### Create a new file `docker-compose.yml`file, please refer to the teleport documentation: https://goteleport.com/docs/getting-started/docker-compose/.

First, we will need to install an authentication and proxy server. This will handle the whole authentication process for all nodes and clients. It also runs a proxy where we can connect to. You can connect to the proxy from a terminal client or via a web client. It also comes with other cool features, I will show you later. I’m running this in a cloud environment because I can easily access this server from anywhere and it’s flexible. But in theory, you could also run this in your home lab or on-premise.

I’m using docker-compose to deploy the teleport proxy and auth server, but you can also install this directly on Linux, without docker if you want. However, I like the containerized deployment because it offers me the most flexibility.

**Example Docker-Compose File**:
```yml
version: '2'
services:
  configure:
    image: quay.io/gravitational/teleport:4.3
    container_name: teleport-configure
    entrypoint: /bin/sh
    hostname: dev.the-digital-life.com
    command: -c "if [ ! -f /etc/teleport/teleport.yaml ]; then teleport configure > /etc/teleport/teleport.yaml; fi"
    volumes:
      - ./config:/etc/teleport

  teleport:
    image: quay.io/gravitational/teleport:4.3
    container_name: teleport
    entrypoint: /bin/sh
    hostname: dev.the-digital-life.com
    command: -c "sleep 1 && /bin/dumb-init teleport start -c /etc/teleport/teleport.yaml"
    ports:
      - "3023:3023"
      - "3024:3024"
      - "3025:3025"
      - "3080:3080"
    volumes:
      - ./config:/etc/teleport
      - ./data:/var/lib/teleport
    depends_on:
      - configure
```

Before you start the container you should change the `hostname` of both containers and set this to the Fully-qualified domain name of your server. You can still change it later in the configuration file, but if you set this up right from the beginning it makes things a lot easier. Then start the docker container with the following command.

### Start the Teleport Server

```bash

```

### Adjust the Config file

When we start this compose file, it will automatically create a default configuration and obtains self-signed certificates. Let’s make some adjustments in the configuration file, which is located in `./config/teleport.yaml`

**Example teleport.yaml**:
```yml
teleport:
    nodename: <your-fqdn>
    data_dir: /var/lib/teleport
    auth_token: <your-auth-token>
    auth_servers:
    - 127.0.0.1:3025
    log:
        output: stderr
        severity: INFO
    ca_pin: sha256:ca-pin-hash-goes-here
auth_service:
    enabled: "yes"
    listen_addr: 0.0.0.0:3025
    public_addr: <your-fqdn>:3025
    tokens:
    - proxy,node:<token>
    license_file: /path/to/license-if-using-teleport-enterprise.pem
ssh_service:
    enabled: "yes"
    labels:
        db_role: master
        db_type: postgres
    commands:
    - name: hostname
        command: [/usr/bin/hostname]
        period: 1m0s
    - name: arch
        command: [/usr/bin/uname, -p]
        period: 1h0m0s
proxy_service:
    enabled: "yes"
    listen_addr: 0.0.0.0:3023
    public_addr: <your-fqdn>
    ssh_public_addr: <your-fqdn>
    web_listen_addr: 0.0.0.0:3080
    tunnel_listen_addr: 0.0.0.0:3024
```

Make sure you add the `public_addr` and `ssh_public_addr` on the auth_service and proxy_service. Replace the `<your-fqdn>` with your FQDN of your teleport server or reverse-proxy/load-balancer.

You also should replace your ca_pin, you can obtain by executing the following command.

```bash
docker-compose exec teleport tctl status
```

After that restart your docker container with the following command.

```bash
docker-compose up -d --force-recreate
```

## How to manage teleport and connect our SSH servers

Now, we will create a user on the teleport auth server. Every teleport user should also map to a user that exists on your nodes. But you can also assign multiple mappings.

```bash
docker-compose exec teleport tctl users add teleport root,xcad,christian,vagrant
```

With this command, I will add a new user called `teleport` who can log in with the Linux users `root`, `xcad`, `christian`, and `vagrant` on the nodes.

This will create a registration token. With the registration token, we can now set up our credentials on the teleport server. Teleport enforces 2FA by default. Install a 2FA like Google Authentication or Authy on your smartphone and scan the QR-Code. Then you can simply enter the 2FA code that is generated on your smartphone.

Now you can simply connect to the docker node with the web interface by accessing `https://<your-fqdn>:3080`

## Add additional SSH servers to teleport

### Create a new access token

To add another node to the proxy server, we need to download and run the teleport client on a server. But first, we need to create a new token on the auth server.

```bash
docker-compose exec teleport tctl nodes add
```

### Install Teleport on your new server

We could now just execute this command on the node, once teleport is downloaded. But I prefer to add this to a static configuration file, that allows me to run the teleport as a systemd service. Download the latest version of teleport and install the package on your node. In this example, I download the .deb package and install it on an Ubuntu server.

```bash
wget https://get.gravitational.com/teleport_4.3.7_amd64.deb
```

### Create a new config for your server

I also create a new configuration file `/etc/teleport.yaml` and add the following values:

**Example teleport.yml**:
```yml
teleport:
    nodename: teleport-node-1
    data_dir: /var/lib/teleport
    auth_token: <your-auth-token>
    auth_servers:
        - <your-fqdn>:3025
    log:
    output: stderr
    severity: INFO
    ca_pin: <your-ca-pin-hash>
auth_service:
    enabled: no
ssh_service:
    enabled: yes
proxy_service:
    enabled: no
```

*Note: If your node doesn't show up with the correct public IP address in your teleport server, you can manually enforce this by adding the attribute to the `teleport:` section in the configuration file.*

```yml
advertise_ip: <servers-public-ip>
```

### Start the new server

Now we can simply start the teleport service with the command:

```bash
sudo systemctl enable –now teleport
```

If everything works successfully, you should be able to see the new node in the teleport proxy server.

## How to add SSH servers through a reverse tunnel to teleport

I also want to test the reverse tunnel for my home lab servers. The trick is to use a teleport reverse tunnel that establishes a connection from inside the network to the cloud server. With this solution, you’re able to connect all SSH servers behind a NAT.

To create a reverse tunnel, simply change the port of the auth server to 3080 in the `/etc/teleport.yaml` configuration file.

```yml
teleport:
    nodename: teleport-node-1
    data_dir: /var/lib/teleport
    auth_token: <your-auth-token>
    auth_servers:
        - <your-fqdn>:3080
    log:
    output: stderr
    severity: INFO
    ca_pin: <your-ca-pin-hash>
auth_service:
    enabled: no
ssh_service:
    enabled: yes
proxy_service:
    enabled: no
```