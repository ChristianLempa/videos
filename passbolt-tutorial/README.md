# Self hosted, open source password manager built for teams!

In this Tutorial we set up a free and open-source password manager for your home labs, or professional it teams, such as DevOps, sysadmins, and so on. We will deploy Passbolt on a docker server and configure a mail server and trusted SSL certificates by using Traefik and Letsencrypt.

Project Homepage: https://www.passbolt.com

Video: https://youtu.be/cEDXeYStfP4

---
## Prerequisites

Before you can deploy Passbolt in Docker, you need a Linux Server that has **Docker**, and **Docker-Compose** installed. You should also have a DNS Record to expose Passbolt with trusted SSL Certificates.

For further References, how to use **Docker**, **Docker-Compose** and **Traefik**, check out my previous videos:
- [How to use Docker and migrate your existing Apps to your Linux Server?](https://www.youtube.com/watch?v=y0GGQ2F2tvs)
- [Docker-Compose Tutorial](https://www.youtube.com/watch?v=qH4ZKfwbO8w)
- [Is this the BEST Reverse Proxy for Docker? // Traefik Tutorial](https://www.youtube.com/watch?v=wLrmmh1eI94)

*You can still install Passbolt on a Linux Server that is not running Docker, however, this may require different commands!*

---
## Install Passbolt in Docker

### Create Docker-Compose file

Copy the example `docker-compose.yml` file in your project directory, and make sure you replace the `APP_FULL_BASE_URL` value with your passbolt's server FQDN.

**Example `docker-compose.yml`**:
```yml
...
version: '3.9'

services:
  db:
    image: mariadb:10.3
    restart: unless-stopped
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=true
      - MYSQL_DATABASE=passbolt
      - MYSQL_USER=passbolt
      - MYSQL_PASSWORD=P4ssb0lt
    volumes:
      - database_volume:/var/lib/mysql

  passbolt:
    image: passbolt/passbolt:latest-ce
    restart: unless-stopped
    depends_on:
      - db
    environment:
      - APP_FULL_BASE_URL=https://passbolt.domain.tld
      - DATASOURCES_DEFAULT_HOST=db
      - DATASOURCES_DEFAULT_USERNAME=passbolt
      - DATASOURCES_DEFAULT_PASSWORD=P4ssb0lt
      - DATASOURCES_DEFAULT_DATABASE=passbolt
    volumes:
      - gpg_volume:/etc/passbolt/gpg
      - jwt_volume:/etc/passbolt/jwt
    command: ["/usr/bin/wait-for.sh", "-t", "0", "db:3306", "--", "/docker-entrypoint.sh"]

volumes:
  database_volume:
  gpg_volume:
  jwt_volume:

...
```

### Mail Server Configuration

Passbolt sends recovery instructions and notifications via email. Therefore, it's important you configure an email account that is allowed to send emails to the users.

**Example `docker-compose.yml`**:
```yml
...
  passbolt:
    ...
    environment:
      ...
      - EMAIL_TRANSPORT_DEFAULT_HOST=your-mail-server
      - EMAIL_TRANSPORT_DEFAULT_PORT=587
      - EMAIL_TRANSPORT_DEFAULT_USERNAME=$EMAIL_TRANSPORT_DEFAULT_USERNAME
      - EMAIL_TRANSPORT_DEFAULT_PASSWORD=$EMAIL_TRANSPORT_DEFAULT_PASSWORD
      - EMAIL_TRANSPORT_DEFAULT_TLS=true
      - EMAIL_DEFAULT_FROM=no-reply@domain.tld
...
```

If you want to store your mail server credentials in a secure place, create an `.env` file in the project directory.

**Example `.env`:**
```
...
EMAIL_TRANSPORT_DEFAULT_USERNAME=mailuser
EMAIL_TRANSPORT_DEFAULT_PASSWORD=your-secret-mailuser-password
```

### Get trusted SSL Certificates via Traefik

The `docker-compose.yml` example contains labels to expose Passbolt via Traefik. Make sure you replace the `traefik.http.routers.passbolt-http.rule`, and `traefik.http.routers.passbolt-https.rule` with your custom rule-set, e.g. Passbolt server's FQDN.

**Example `docker-compose.yml`**:
```yml
...
  passbolt:
    ...
    labels:
      traefik.enable: "true"
      traefik.http.routers.passbolt-http.entrypoints: "web"
      traefik.http.routers.passbolt-http.rule: "Host(`passbolt.domain.tld`)"
      traefik.http.routers.passbolt-http.middlewares: "SslHeader@file"
      traefik.http.routers.passbolt-https.middlewares: "SslHeader@file"
      traefik.http.routers.passbolt-https.entrypoints: "websecure"
      traefik.http.routers.passbolt-https.rule: "Host(`passbolt.domain.tld`)"
      traefik.http.routers.passbolt-https.tls: "true"
      traefik.http.routers.passbolt-https.tls.certresolver: "letsencrypt"
...
```

Copy the `traefik.yaml`, `conf/headers.yaml`, and `conf/tls.yaml` in your project directory.

Make sure, you customize your settings in the `traefik yaml`.

**Example `traefik.yaml`**:
```yml
...
certificatesResolvers:
  letsencrypt:
    acme:
      email: yourname@domain.tld
      storage: /shared/acme.json
      caServer: 'https://acme-v02.api.letsencrypt.org/directory'
      keyType: EC256
      httpChallenge:
        entryPoint: web
      tlsChallenge: {}
...
```

### (Optional) Avoid conflicts with other containers

To avoid conflicts with other running containers, you should disable the `exposedByDefault` setting in the `traefik yaml`.

**Example `traefik.yaml`**:
```yml
...
providers:
  docker:
    ...
    exposedByDefault: false
...
```

### (Optional) Use DNS Challenge on Cloudflare

To enable DNS Challenge for trusted SSL Certificates (f.e. via Cloudflare), make sure you customize the `docker-compose.yml`, and `traefik.yaml` and insert your custom settings.

**Example `docker-compose.yml`**:
```yml
...
  passbolt:
    ...
    labels:
      ...
      traefik.http.routers.passbolt-https.tls.certresolver: "cloudflare"
  traefik:
    ...
    environment:
      - CF_API_EMAIL=$CF_API_EMAIL
      - CF_API_KEY=$CF_API_KEY
```

**Example `traefik.yaml`**:
```yml
...
certificatesResolvers:
  cloudflare:
    acme:
      email: yourname@domain.tld
      storage: /shared/acme.json
      caServer: 'https://acme-v02.api.letsencrypt.org/directory'
      keyType: EC256
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "8.8.8.8:53"
...
```

Make sure you pass the DNS Providers Credentials via the `.env` file into the Traefik container.

**Example `.env`:**
```
...
CF_API_EMAIL=your-mail-address
CF_API_KEY=your-secret-api-key
```


### Start the container and create your first user

To start the container, execute the following command in the project directory.

```bash
docker-compose up -d
```

Create your first user with the following command.

```bash
docker-compose exec passbolt su -m -c "/usr/share/php/passbolt/bin/cake \
passbolt register_user \
-u <your@email.com> \
-f <yourname> \
-l <surname> \
-r admin" -s /bin/sh www-data
```

Login with your user and create your private key and passphrase. Make sure, you store the private key in a secure location.

---
## References

- [Docker passbolt installation](https://help.passbolt.com/hosting/install/ce/docker.html)
- [Configure email providers](https://help.passbolt.com/configure/email/setup)
- [Auto configure HTTPS with Let's Encrypt on Docker](https://help.passbolt.com/configure/https/pro/docker/auto)