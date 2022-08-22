# Backup in Linux Servers - Docker Volumes, and Databases
Backup in Linux doesn't need to be complicated. I'll show you backup strategies and tools to create a reliable backup for your entire Linux server. You can use this perfectly in combination with Docker Volumes and Databases.

We will use the free and open-source software Duplicati.


Project Homepage: https://www.duplicati.com
Documentation: https://duplicati.readthedocs.io/en/latest/
Source Files: https://github.com/duplicati/duplicati

Video: https://youtu.be/JoA6Bezgk1c

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

## 2. Set up Duplicati

### 2.1. Create a Docker-Compose file

Create a new `docker-compose.yml` file in your project folder e.g. `/home/<your-username>/nextcloud`.

*You can also create a new folder in the `/opt` directory, this may require different permissions.*

### 2.2. Start Duplicati

Navigate to your project folder, and execute the following command.

```bash
docker-compose up -d
```

### 2.3. Configure Duplicati

Open the web interface of **Duplicati** at `http://your-server-address:8200`, and log in with the default username, and password `...` / `...`. 
