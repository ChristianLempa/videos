# This web UI for Ansible is so damn useful

Ansible Semaphore is the perfect tool for automating your servers, applications, and clean up tasks with Ansible Playbooks. In this video, I'll quickly show you how to install it and some of the stuff you can do with it. If you're new to Ansible, I recommend checking out some of my older videos first to get some foundational knowledge. Let's get started automating your Homelab with Ansible Semaphore!

Video: https://youtu.be/NyOSoLn5T5U


---
## Prerequisites

- Linux Server with Docker installed
- Some basic knowledge about Ansible

---
## Install Ansible-Semaphore

Ansible-Semaphore can be easily installed on a Linux machine using a snap command, Linux packages, or Docker. To install Ansible-Semaphore, you can use the following Docker Compose file, as an example.

```yaml
---
volumes:
  semaphore-mysql:
    driver: local
services:
  mysql:
    image: mysql:8.0
    hostname: mysql
    volumes:
      - semaphore-mysql:/var/lib/mysql
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=yes
      - MYSQL_DATABASE=semaphore
      - MYSQL_USER=semaphore
      - MYSQL_PASSWORD=secret-password  # change!
    restart: unless-stopped
  semaphore:
    container_name: ansiblesemaphore
    image: semaphoreui/semaphore:v2.8.90
    user: "${UID}:${GID}"
    ports:
      - 3000:3000
    environment:
      - SEMAPHORE_DB_USER=semaphore
      - SEMAPHORE_DB_PASS=secret-password  # change!
      - SEMAPHORE_DB_HOST=mysql
      - SEMAPHORE_DB_PORT=3306
      - SEMAPHORE_DB_DIALECT=mysql
      - SEMAPHORE_DB=semaphore
      - SEMAPHORE_PLAYBOOK_PATH=/tmp/semaphore/
      - SEMAPHORE_ADMIN_PASSWORD=secret-admin-password  # change!
      - SEMAPHORE_ADMIN_NAME=admin
      - SEMAPHORE_ADMIN_EMAIL=admin@localhost
      - SEMAPHORE_ADMIN=admin
      - SEMAPHORE_ACCESS_KEY_ENCRYPTION=  # add to your access key encryption !
      - ANSIBLE_HOST_KEY_CHECKING=false  # (optional) change to true if you want to enable host key checking
    volumes:
      - ./inventory/:/inventory:ro
      - ./authorized-keys/:/authorized-keys:ro
      - ./config/:/etc/semaphore:rw
    restart: unless-stopped
    depends_on:
      - mysql
```

Modify the file by changing the database password, adding a strong admin password, and generating a new access key encryption. Ansible Semaphore stores sensitive information such as SSH keys or passwords in the database, so it's important to use a secret access key. 

You can generate this with the following command.

```sh
head -c32 /dev/urandom | base64
```

Start the container with a `docker compose up -d` command.

---
## References

- [Ansible-Semaphore Documentation](https://docs.ansible-semaphore.com)