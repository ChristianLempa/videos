# Install a mail server on Linux in 10 minutes - docker, docker-compose, mailcow

Mail Server Linux Installation in 10 minutes? Here, you will learn step-by-step how to install and set up all necessary applications to have a fully featured mail server. And trust me, you can do it in about 10 minutes!

We will use the free and open-source project **Mailcow Dockerized** which is a fully featured mail server powered by Docker.

Project Homepage: https://mailcow.email/
Project Source: https://github.com/mailcow/mailcow-dockerized
Documentation: https://mailcow.github.io/mailcow-dockerized-docs/

Video: https://www.youtube.com/watch?v=4rzc0hWRSPg

## Prerequisites

- Linux Server running Ubuntu 18.04 LTS or newer

You can still install mailcow on a Linux Server that is not running Ubuntu, however, this may require different commands!

## Installation and Configuration

1. Install Docker
```
sudo apt update

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

sudo apt-get install docker-ce docker-ce-cli containerd.io

```

2. Check if Docker is installed correctly

```
sudo docker run hello-world
```

3. Install Docker-Compose

Download the latest version (in this case it is 1.25.5, this may change whenever you read this tutorial!)

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

4. Check if Docker-Compose is installed correctly

```
sudo docker-compose --version
```

5. Install mailcow-dockerized

Clone mailcow into the `/opt` folder.

You can also use your personal home folder `/home/<your-username>`, this may require different permissions.

```
sudo git clone https://github.com/mailcow/mailcow-dockerized
```

6. Generate your configuration file and follow the steps in the script.

```
sudo ./generate_config.sh
```

7. Enter your mailserver FQDN (this is your mailserver hostname, not your domain name)

8. Select your timezone

9. (optional) Insert custom SSL certificate

If you start "mailcow" it will automatically generate and request a letsencrypt certificate for your domains. If you don't want that, but instead use your own certificate you need to modify the `mailserver.conf` and change the line to:

```
SKIP_LETS_ENCRYPT=y
```

10. Start mailcow

```
sudo docker-compose up -d
```

11. Login to mailcow

When all services are started successfully, you can now login to the admin dashboard and configure your domain, mailboxes, aliases, etc.

The admin dashboard can be accessed by `https://<your-mailservers-fqdn>`

The default username is `admin`, and the password is `moohoo`

12. Set up your domain(s)

You need to set up your domain first at `Configuration -> Mail Setup -> Domains`.

13. Set up your mailbox(es)

If you want to configure your mailboxes, you can add them at `Configuration -> Mail Setup -> Mailboxes`.

