# Docker Alternative with Podman, Cockpit, and Nginx Proxy Manager
Docker Alternative with Podman, Cockpit, and Nginx Proxy Manager to manage your Linux server easily and securely! We will install an Ubuntu 21.04 Server and deploy it with a nice management web UI protected with a reverse proxy.

We will use the free and open-source software Podman.


Project Homepage: https://podman.io/
Documentation: https://docs.podman.io/en/latest/

Video: https://youtu.be/-hJosY_M0I4

## Prerequisites

- Linux Server running Ubuntu 21.04 LTS or newer

You can still install Podman on a Linux Server that is not running Ubuntu, however, this may require different commands!

*For older Ubuntu versions or other Linux Distributions, just follow the [official installation instructions](https://podman.io/getting-started/installation).*

## 1. Install Podman, and Podman-Compose

### 1.1. Install Podman

You can install Podman on Linux, macOS, or Windows. In our example, because we're using Ubuntu 21.04, we can just install it from the Ubuntu repository.

```bash
sudo apt install podman
```

### 1.2. Install Podman-Compose

```
sudo apt install python3-pip
pip3 install podman-compose
```

You can also put this command into your `.bashrc` or `.zshrc` file to make it persistent!

```bash
export PATH=$PATH:$HOME/.local/bin
```

## 2. Install Cockpit

### 2.1. Install Cockpit

Note, if you're using an older version of Ubuntu, I wouldn't necessarily recommend upgrading yet. Especially if you are using the LTS version, keep running it. The only package that's not available in older LTS versions of Ubuntu is the cockpit-podman package. So, my experience is, that it works best with Ubuntu 21.04 and probably newer versions as well.

With the following command, we install Cockpit and the Podman extension.

```bash
sudo apt install cockpit cockpit-podman
```

### 2.2. Access Cockpit

When the installation was successful, just access it on port 9090. The interface is very easy and intuitive. You can manage your entire Linux server, update packages, set up basic configuration, and manage containers with Podman.

## 3. Expose Cockpit with Nginx Proxy Manager

### 3.1. Change unprivileged ports

Before we can start running Podman containers rootless, we need to configure unprivileged ports. Because by default, Podman doesn't allow us to expose any ports lower than `1024`, without root privileges.

Simply open the `/etc/sysctl.conf` file and add this line at the end.

```
net.ipv4.ip_unprivileged_port_start=80
```

### 3.2. Deploy Nginx Proxy Manager

Create a new file `docker-compose.yml`file, please refer to the nginxproxymanager documentation: https://nginxproxymanager.com/guide/.

...

**Example Docker-Compose File**:
```yml
version: '3'

volumes:
  nginxproxymanager-data:
  nginxproxymanager-ssl:
  nginxproxymanager-db:

services:
  nginxproxymanager:
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
      - nginxproxymanager-data:/data
      - nginxproxymanager-ssl:/etc/letsencrypt
  nginxproxymanager-db:
    image: 'jc21/mariadb-aria:latest'
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - nginxproxymanager-db:/var/lib/mysql
```

### 3.3. Start the Nginx Proxy Manager

```bash
podman-compose up -d
```

### 3.4. Login to the web UI of NGINX proxy manager

Now we can log in to the web UI. Simply use your browser to connect to your server by using the IP address or an FQDN and connect on port `81`. Log in with the username `admin@example.com` and the password `changeme`. Next, you should change your username and password, and that’s it!

### 3.5. Configure a new Proxy Host

Add a new Proxy Host and make sure you select the port HTTPS because Cockpit is using HTTPS by default. As a Forward Hostname / IP just use the internal or public IP address of your server. If you use the internal IP address, you can limit the listening address of Cockpit later. With this method, you're disabling access from external networks without going through the reverse proxy! 

In this example, I've used the public DNS name npm3.the-digital-life.com and forwarded it to the internal IP address of my server, using the Cockpit Port 9090.

### 3.6. (optional) Stop listening on Port 9090

Let's also limit access to our Cockpit Web Interface. Because you could still just use the public IP address on the port 9090 to access Cockpit. If you have used the server's internal IP address in Nginx Proxy Manager, you can now limit access to this IP address. So that only Nginx Proxy Manager and other internal servers are able to connect to our administrative interface.

Create a new file `/etc/systemd/system/cockpit.socket.d/listen.conf` and add the following lines.

```conf
[Socket]
ListenStream=
ListenStream=<internal-ip-address>:9090
FreeBind=yes
```

To make these settings active, execute the following commands in the terminal.

```bash
sudo systemctl daemon-reload

sudo systemctl restart cockpit.socket
```

