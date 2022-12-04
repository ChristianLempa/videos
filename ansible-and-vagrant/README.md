# Automate your Docker deployments with Ansible
Ansible Docker Deployments for your Servers made easily! In this video, I'll show you how I've used Ansible to automate my webserver deployments. We're deploying Portainer, Watchtower, and a WordPress Blog.

We will use the free and open-source software Ansible by Red Hat.

Project Homepage: https://www.ansible.com/
Documentation: https://docs.ansible.com/


Video: https://youtu.be/CQk9AOPh5pw

## Prerequisites

- Linux, macOS or Windows 10, 11 with WSL2 (Debian or Ubuntu) running Ansible
- Linux Server for testing

*To set up Linux, macOS or Windows 10, 11 with WSL2 running Ansible, follow my [Ansible Tutorial](https://github.com/xcad2k/videos/tree/main/ansible-tutorial)*

## 1. Installation and Configuration

### 1.1. Install the Docker Galaxy Extension for Ansible

Now, we can install the Ansible Galaxy Extension to manage Docker containers on remote servers. Simply execute the following command.

```bash
ansible-galaxy collection install community.docker
```

### 1.2. Configure our Ansible Environment

Let's start configuring our Ansible Environment. Because we need to set up an ansible.cfg and inventory file in our project folder to tell Ansible how to connect to our remote server. The inventory file is a simple text file that just contains the IP address of our server.

**Example Ansible Configuration**:
```conf
[defaults]
inventory = inventory
host_key_checking = False  # optional: removes the SSH prompt 
deprecation_warnings=False  # optional: removes deprecation warning in playbooks
remote_user = <remote-user>
private_key_file = <remote-user-private-key-file>
```

### 1.3. (optional) Test Ansible Connection

If everything is configured correctly, you can test the connection with the following command.

```bash
ansible all -m ping
```

## 2. Install Docker on our remote Server

If we have configured our Ansible Environment, we can install all necessary components on our remote server. Because I installed a fresh new Ubuntu 20.04 LTS server, we need to install Docker first. And also the Docker Python SDK is required by Ansible to run containers on remote servers. Therefore, you have two options to install everything on the remote server.

**Option 1: Manual installation of all components**

When you want to install the components manually, just have a look at the Docker Installation Documentation. You also need to install Python, the Python Package Manager, and the Docker SDK.

**Option 2: Install Docker with an Ansible Playbook**

Since we already have configured Ansible to manage our remote server, why shouldn't we use it? Because I've already prepared an Ansible Playbook, you can just download and run it. You will find this Playbook in my GitHub Repository Ansible-Boilerplates, and it will install Docker and the Python Docker SDK for you.

## 3. Run Portainer with Ansible

### 3.1. Write Ansible Playbook

Now we're ready to deploy our first Docker container with Ansible! Create a new Ansible Playbook YAML file in your project folder, that should look like this.

```yml
- hosts: all
  become: yes
  tasks:

    - name: Deploy Portainer
      community.docker.docker_container:
        name: portainer
        image: portainer/portainer-ce
        ports:
          - "9000:9000"
          - "8000:8000"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer_data:/data
        restart_policy: always
```

### 3.2. Run Ansible Playbook

To run the Ansible Playbook, simply execute the following command in the shell.

```bash
ansible-playbook <playbook-file.yaml>
```

## 4. Run Watchtower with Ansible

### 4.1. Write Ansible Playbook

To run our second Docker container, we simply can just add another task inside the same Ansible Playbook. Because Ansible will take care of which Containers are already deployed and if there are any changes to be made. And it only re-deploys containers if there are changes being made.

```yml
    - name: Deploy Watchtower
      community.docker.docker_container:
        name: watchtower
        image: containrrr/watchtower
        command: --schedule "0 0 4 * * *" --debug
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        restart_policy: always
```

Simply run the Playbook with the same command above again. You can see that the task "Portainer" is not executed again, only our new task "Watchtower".

## 5. Deploy a Wordpress Blog with Ansible and Docker

### 5.1. Write Ansible Playbook

Let's also deploy two more containers, to automate the deployment of my webserver. Because I want to run a WordPress Blog on this server, we execute the following Playbook.

We also need to create a new Network before running the Containers. Otherwise, WordPress will not be able to connect to the Database Container. Therefore we also need to attach them to the same Network.

```yml
- hosts: all
  become: yes
  tasks:

    - name: Create Network
      community.docker.docker_network:
        name: wordpress

    - name: Deploy Wordpress
      community.docker.docker_container:
        name: wordpress
        image: wordpress:latest
        ports:
          - "80:80"
        networks:
          - name: wordpress
        volumes:
          - wordpress:/var/www/html
        env:
          WORDPRESS_DB_HOST: "db"
          WORDPRESS_DB_USER: "exampleuser"
          WORDPRESS_DB_PASSWORD: "examplepass"
          WORDPRESS_DB_NAME: "exampledb"
        restart_policy: always

    - name: Deploy MYSQL
      community.docker.docker_container:
        name: db
        image: mysql:5.7
        networks:
          - name: wordpress
        volumes:
          - db:/var/lib/mysql
        env:
          MYSQL_DATABASE: "exampledb"
          MYSQL_USER: "exampleuser"
          MYSQL_PASSWORD: "examplepass"
          MYSQL_RANDOM_ROOT_PASSWORD: '1'
        restart_policy: always
```