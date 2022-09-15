# Teleport Passwordless
The best password is NO password! Let's add my new YubiKey as a passwordless authentication method in Teleport. That allows me to access all my Linux Servers, Kubernetes Clusters, Web Applications, Databases and RDP without remembering any password (but still is much more secure!)

We will use the free and open-source software teleport.

Project Homepage: https://goteleport.com
Documentation: https://goteleport.com/docs/access-controls/guides/passwordless/

Video: https://youtu.be/I10mtZfVZ1Q

## Prerequisites

- A Linux server running Ubuntu (20.04 LTS or newer) with Docker, and Docker-compose installed
- You must have a public domain that should match the `public_addr` in the teleport.yml config file
- The ports `3023`, `3024`, `3025` and `443` need to be accessible on the server

*To set up a demo server using **Ubuntu 22.04 LTS** on **CIVO** and create a public DNS Record at **Cloudflare**, you can use the **Terraform** Template and **Ansible** Playbook in the `demo-server/` directory.*

## Install and configure the teleport

### (Optional) Generate teleport config file

*This step is optional because you can also copy/paste the file `.config/teleport.yml` and modify it according to your needs.*

Generate a teleport config file `.config/teleport.yml` from scratch.

```bash
docker run --hostname localhost --rm --platform linux/amd64 --entrypoint=/bin/sh -v /Users/xcad/Projects/videos/teleport-passwordless/config:/etc/teleport -it quay.io/gravitational/teleport:10 -c "teleport configure > /etc/teleport/teleport.yml"
```

Change the following fields in the teleport config file `.config/teleport.yml`.

```
teleport:
  nodename: <your-servername>
auth_service:
  cluster_name: <your-servers-fqnd>
proxy_service:
  web_listen_addr: 0.0.0.0:443
  public_addr: <your-servers-fqdn>:443
  acme:
    enabled: yes
    email: <your-email-address>
```

### Upload files to server
```
scp docker-compose.yml config data <servername>:~/teleport-passwordless/
```

Check permissions of the directory, they should match the `uid:gid` in the compose file

### Start teleport server

Start the teleport server, and check if the certificates are generated correctly.

```
docker-compose up
```

### (Optional) Start teleport server in background mode

Start the teleport server in background mode.

```bash
docker-compose up -d
```

Check if the server has been started successfully.

```bash
docker-compose ps
```

## Create user

//TODO description text

```
docker exec -it teleport tctl users add xcad --roles=editor --logins=root,xcad
```

//TODO steps in the web ui

## Passwordless authentication

### Enable passwordless in teleport

Change the following fields in the teleport config file `.config/teleport.yml`.

```
auth_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3025
  proxy_listener_mode: multiplex
  cluster_name: <your-servers-fqdn>
  authentication:
    type: local
    second_factor: on
    webauthn:
      rp_id: <your-servers-fqdn>
    connector_name: passwordless
```

### Add a passwordless multifactor hardwarekey

//TODO add steps in the web ui

You can also add a multifactor hardwarekey via tsh.

```bash
tsh mfa add
```

### (Optional) Use touchid in Mac OS

//TODO add description for touchid

