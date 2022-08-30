# Simple automation for all your Linux servers with Ansible
We take a look at how to automate Linux servers with Ansible. We also cover authentication via SSH user/password and private/public keys you should use in a production environment.

We will use the free and open-source software Ansible by Red Hat.

Project Homepage: https://www.ansible.com/
Documentation: https://docs.ansible.com/

Video: https://youtu.be/uR1_hlHxvhc

## Prerequisites

- Linux, macOS or Windows 10, 11 with WSL2
- Linux Server for testing

## Installation and Configuration

1. Install Ansible on your machine

First, you need to install Ansible on your system. Just go to https://docs.ansible.com/ and follow the installation instructions for your Linux distribution. You can also set up this in a virtual machine or on Windows Subsystem for Linux.

2. Configure ansible.cfg

Before we can connect to other machines, we need to set up a general Ansible configuration file. This is very helpful, otherwise, we would need to enter all settings as options in our ansible commands. You can either edit the general Ansible Configuration file under `/etc/ansible/ansible.cfg` or create a new `ansible.cfg` in a project folder. By default, Ansible will check if there is an `ansible.cfg` file in your current folder which will overwrite the default settings.

**Example ansible.cfg**:
```config
[defaults]
inventory = inventory
host_key_checking = False
```

3. Configure your inventory

You should always specify an **inventory** file, that you can place in your project folder. This inventory file contains all IP addresses and also configuration variables of the machines you want to control.

**Example inventory**:
```
[nodes]
192.168.0.139
192.168.0.140

[master]
192.168.0.138

[master:vars]
ansible_ssh_user=master
ansible_ssh_pass=master

[nodes:vars]
ansible_ssh_user=vagrant
ansible_ssh_pass=vagrant
```

4. Configure authentication

Next, you should think about how Ansible authenticates to your machines. There are generally two different methods. The first method is via usernames and passwords, which you can simply define either in the general `ansible.cfg` file. If some machines in your inventory require a different username and/or password you can also configure that separately in your inventory file by using the `[<name>:vars]` section. In this case, you also need to install the `sshpass` package on your Ansible machine and add `host_key_checking = False` in the default section of your ansible.cfg file.

*Note it is not the best and most secure method and should not be used in production environments! In any production environment, you should create a corresponding private and public key pair for Ansible and upload the public key on all machines.*

5. (optinonal) More secure authentication with private and public ssh keys

**Example Inventory**:
```
[nodes]
192.168.0.139
192.168.0.140

[master]
192.168.0.138

[nodes:vars]
ansible_ssh_user=christian
ansible_ssh_private_key_file=~/.ssh/ansible_id_rsa

[master:vars]
ansible_ssh_user=master
ansible_ssh_private_key_file=~/.ssh/ansible_id_rsa
```

## Test Connection

Now that we have configured Ansible and can connect to our machines we can execute some test commands. This command will ping all machines that are in our inventory file.

```bash
ansible all -m ping
```

*You can also change the pattern from `all` to a specific section you have defined in your inventory file. Let’s only ping the nodes, and exclude the master.*

```bash
ansible nodes -m ping
```

## Ansible Playbooks

Ansible playbooks can describe even complex automation tasks simply and effectively. It uses the YAML (Yet another markup language) standard, which is easily readable by humans and interpreted by machines. You can define a state where you want all your machines to be in. Ansible will take care of the rest and perform the necessary actions on the machines.

First, you need to start with a pattern of machines, you want to define a state for. You can also choose which user you want to use to execute any actions and if Ansible needs to execute commands with root privileges. For every pattern, you can describe one or more tasks to call Ansible modules. In the following example, we’re installing some software packages on the master server and nodes.

**Example Playbook**:
```yml
---
- hosts: nodes
  become: yes
  tasks:
  - name: make sure net-tools are installed on all nodes
    apt:
      name: net-tools
      state: present
```

If you want to execute an Ansible playbook you need to use the command `ansible-playbook`. Note, that for installing software packages you need to become a root user. This can be done by the option `become`, which requires you to provide a **sudo** password either via the default or inventory configuration, or arguments in the command.

```bash
ansible-playbook playbook.yaml -K
```

You can see that Ansible executed all tasks successfully, but it didn’t always change something. This is because some packages are already installed on the machines. Ansible only installs a package when it’s not installed already.