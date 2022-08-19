# Nginx Proxy Manager - How-To Installation and Configuration
In this Nginx Proxy Manager How-To, I'll show you how to install and configure Nginx Proxy Manager in Docker.

We will use the free and open-source software Nginx Proxy Manager.


Project Homepage: https://nginxproxymanager.com/
Documentation: https://nginxproxymanager.com/guide/

Video: https://youtu.be/P3imFC7GSr0

## Prerequisites

- Linux Server running Ubuntu 20.04 LTS or newer
- Domain that points to the public IP of your Linux Server

You can still install Docker on a Linux Server that is not running Ubuntu, however, this may require different commands!

## 1. Install Docker, and Docker-Compose

You can still install Docker on a Linux Server that is not running Ubuntu, however, this may require different commands!

### 1.1. Install Docker
```bash
sudo apt update

sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

sudo apt-get install docker-ce docker-ce-cli containerd.io
```

### 1.2. Check if Docker is installed correctly
```bash
sudo docker run hello-world
```

### 1.3. Install Docker-Compose

Download the latest version (in this case it is 1.25.5, this may change whenever you read this tutorial!)

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### 1.4. Check if Docker-Compose is installed correctly
```bash
sudo docker-compose --version
```

### 1.5. (optional) Add your linux user to the `docker` group
```bash
sudo usermod -aG docker $USER
```

## 2. Set up Nginx Proxy Manager

### 2.1. Create a new file `docker-compose.yml`file, please refer to the nginxproxymanager documentation: https://nginxproxymanager.com/guide/.

...

**Example Docker-Compose File**:
```yml
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "npm"
      DB_MYSQL_PASSWORD: "npm"
      DB_MYSQL_NAME: "npm"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
  db:
    image: 'jc21/mariadb-aria:latest'
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - ./data/mysql:/var/lib/mysql
```

### 2.2. Start the Nginx Proxy Manager

```bash
docker-compose up -d
```

## 3. Login to the web UI of NGINX proxy manager

Now we can log in to the web UI. Simply use your browser to connect to your server by using the IP address or an FQDN and connect on port `81`. Log in with the username `admin@example.com` and the password `changeme`. Next, you should change your username and password, and that’s it!

