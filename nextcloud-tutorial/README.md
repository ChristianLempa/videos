# Nextcloud Nginx Proxy Manager in 10 Minutes!
Nextcloud Nginx Proxy Manager fast and easy tutorial in just 10 Minutes with trusted SSL Certs! We're using Docker, Docker-Compose, or Portainer to deploy this on a Linux Server.

We will use the free and open-source software Nextcloud.

**Nextcloud**:
Project Homepage: https://nextcloud.com/

**Nginx Proxy Manager**:
Project Homepage: https://nginxproxymanager.com/
Documentation: https://nginxproxymanager.com/guide/

Video: https://youtu.be/iFHbzWhKfuU

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

## 2. Set up Nextcloud

### 2.1. Create a Docker-Compose file

Create a new `docker-compose.yml` file in your project folder e.g. `/home/<your-username>/nextcloud`.

*You can also create a new folder in the `/opt` directory, this may require different permissions.*

### 2.2. Start Nextcloud

Navigate to your project folder, and execute the following command.

```bash
docker-compose up -d
```

### 2.3. Configure Nginx Proxy Manager

Open the web interface of **Nginx Proxy Manager** at `http://your-server-address:81`, and log in with the default username, and password `admin@example.com` / `changeme`. 

Create a new Proxy Host, and fill in a subdomain e.g. `nextcloud.your-server-address` as the domain name and forward it to `nextcloud-app` on port `80`.

*You can obtain a free SSL certificate from letsencrypt to securely expose Nextcloud via HTTPS.*

### 2.4. Configure Nextcloud

Open the web interface of **Nextcloud** at `https://nextcloud.your-server-address`, and log in with the default username, and password `admin` / `admin`. 

## 3. (optional) Fix issues

### 3.1. Desktop Client Sync does not work

If you have issues with Desktop Client Sync, you need to change the `config/config.php` file and add the following line.

```
'overwriteprotocol' => 'https'
```
