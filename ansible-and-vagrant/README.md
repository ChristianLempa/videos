# Automate your virtual lab environment with Ansible and Vagrant
I show you how you can easily automate a full lab environment containing multiple virtual machines using Vagrant and Ansible.

We will use the free and open-source software Ansible by Red Hat, and the free and open-source software Vagrant by Hashicorp.

**Ansible**:
Project Homepage: https://www.ansible.com/
Documentation: https://docs.ansible.com/

**Vagrant**:
Project Homepage: https://www.vagrantup.com/
Documentation: https://www.vagrantup.com/docså
Find Boxes: https://app.vagrantup.com/boxes/search

Video: https://youtu.be/7Di0twyxw1M

## Prerequisites

- Linux, macOS or Windows 10, 11 with WSL2 (Debian or Ubuntu)
- Linux Server for testing

## Installation and Configuration

1. Use Vagrant with Ansible on Windows 10, 11

If you’re running Vagrant on Linux, you can skip this part. But if you’re running Vagrant on Windows with VirtualBox or Hyper-V, you have a problem. Because Ansible is not running on Windows, you will need to run Vagrant with Ansible scripts on a Linux machine. Luckily, you can do this pretty easily with the Windows Subsystem for Linux (WSL2). Because the trick is to install Vagrant on your WSL machine and on your Windows 10, too. Note, that it needs to be installed exactly in the same version and it’s still considered a beta version at this time.

To install Vagrant on WSL just simply download the latest version at https://releases.hashicorp.com/vagrant/.

```bash
wget https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.deb

sudo apt install ./vagrant_2.2.10_x86_64.deb
```

Next, you need to add a few environment variables according to https://www.vagrantup.com/docs/other/wsl.html. If you’re running bash, simply add them to your .bashrc file. On zsh you need to place them in your .zshrc file.

```
VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH=/mnt/c/Users/<your-personal-folder>
VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
```

On Windows 10, 11 with Hyper-V, set the default provider with the following environment variable.

```
VAGRANT_DEFAULT_PROVIDER=hyperv
```

Check if Vagrant is running on your WSL2 and can communicate to the Hypervisor on your Windows 10 by executing the vagrant command. If and error shows up, you probably haven’t loaded the environment variables correctly.

2. Install Ansible

```
sudo apt-add-repository ppa:ansible/ansible

sudo apt update

sudo apt install ansible
```

## Set up a Vagrant machine

Now let’s start with the creation of our Vagrantfile. If you’re not familiar with Vagrant yet, you should check out my tutorial about Vagrant, to learn the fundamentals. When you’re running Vagrant with VirtualBox, the configuration will look slightly different, because I’m using Hyper-V as my default provider. Any Virtualbox fans can just comment out the HyperV subconfiguration part.

**Example Vagrantfile**:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    config.vm.define "master" do |subconfig|
        subconfig.vm.box = "generic/ubuntu2004"
        subconfig.vm.hostname = "master"
        subconfig.vm.provider "hyperv"
        subconfig.vm.network "public_network", bridge: "BRIDGE"

        subconfig.vm.provider "hyperv" do |h|
            h.enable_virtualization_extensions = false
            h.linked_clone = false
            h.vmname = "ubuntu_cluster_master"
        end

        subconfig.vm.provision "ansible" do |a|
            a.verbose = "v"
            a.playbook = "master_playbook.yaml"
        end
    end
end
```

If you later want to add more than one virtual machine, it’s useful to create a sub config for every single machine.

```ruby
config.vm.define "master" do |subconfig|
```

We can automatically attach our virtual machine(s) to a virtual switch in Hyper-V with the following statement.  Because the “BRIDGE” Interface is the name of my virtual switch that connects the virtual machine to my physical network adapter.

```ruby
subconfig.vm.network "public_network", bridge: "BRIDGE"
```

This h configuration is part of the provider-specific configuration of the Hyper-V on Windows 10. For more information check out this blogpost.

```ruby
subconfig.vm.provider "hyperv" do |h|
    h.enable_virtualization_extensions = false
    h.linked_clone = false
    h.vmname = "ubuntu_cluster_master"
end
```

Now we will create another subconfiguration to provision the machine with an ansible-playbook. This will contain all ansible instructions to provision our virtual machine. Vagrant automatically executes the ansible-playbook once the virtual machine is created the first time.

```ruby
    subconfig.vm.provision "ansible" do |a|
        a.verbose = "v"
        a.playbook = "master_playbook.yaml"
    end
```

## Create Ansible Playbook

Now, we need to create your ansible-playbook that is used to provision our virtual machine. I’ve created an example of a playbook that will automatically install Docker. Of course, you can simply change the playbook to whatever your need is. By the way, you find useful examples on my GitHub repository ansible-boilerplates. Of course, you can simply use and modify them in a variety of different setups.

Because Vagrant completely handles the provisioning and authentication part, you don’t need to enter any passwords or public SSH keys.

```yml
- hosts: all
    become: yes
    tasks:
    - name: install prerequisites
    apt:
        name:
        - apt-transport-https
        - ca-certificates 
        - curl 
        - gnupg-agent
        - software-properties-common
    - name: add apt-key
    apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
    - name: add docker repo
    apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu focal stable
    - name: install docker 
    apt:
        name: 
        - docker-ce
        - docker-ce-cli
        - containerd.io
        update_cache: yes
    - name: add userpermissions
    shell: "usermod -aG docker vagrant"
```

## Start the Lab Environment

Now, start the virtual lab environment. Just execute `vagrant up`, and Vagrant will create the virtual machine, install the box image, and provision it with the ansible-playbook. After that, you should see that all tasks are applied.

```bash
vagrant up
```

### Connect to the Lab Environment

```
vagrant ssh
```

