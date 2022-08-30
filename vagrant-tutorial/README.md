# Automated virtual machine deployment with Vagrant
In this tutorial, I will show you how to easily automate the deployment of a virtual machine with Vagrant running on Windows 10 with Hyper-V

We will use the free and open-source software Vagrant by Hashicorp.

Project Homepage: https://www.vagrantup.com/
Documentation: https://www.vagrantup.com/docs
Find Boxes: https://app.vagrantup.com/boxes/search

Video: https://youtu.be/sr9pUpSAexE

## Prerequisites

- Windows 10 with Microsoft Hyper-V enabled

*You can still use Vagrant Docker on Windows, Linux, or macOS using different Hypervisors like Virtualbox, ..., however, this may require different commands!*

## Installation and Configuration

### Download and Install Vagrant

Download Vagrant from the official Homepage https://www.vagrantup.com/downloads and follow the installation instructions.

### Set up a virtual machine deployment

Let's set up our first virtual machine deployment with Vagrant. You should create a new directory with enough disk space because Vagrant will store the configuration and virtual hard disk in this location. Then, we will initialize a new Vagrantfile with the following command.

```powershell
vagrant init
```

This will create a new Vagrantfile, we can easily inspect and customize. 

### Modify the Vagrantfile

First, we need to change the configuration file to use a specific box. In this tutorial, we're using the `hashicorp/bionic64` box as a quick example. We edit the Vagrantfile and change the box with this line.

```vagrant
...
config.vm.box = "hashicorp/bionic64"
...
```

### (Optional) Running Vagrant on Windows 10

If you're running Hyper-V on Windows 10, Microsoft recommends adding the following entries according to [this official Microsoft Blog-Post](https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20170706-vagrant-and-hyper-v-tips-and-tricks).

```vagrant
...
config.vm.provider "hyperv"
config.vm.synced_folder ".", "/vagrant", disabled: true

config.vm.provider "hyperv" do |h|
  h.enable_virtualization_extensions = true
  h.linked_clone = true
end
...
```

Note: If you're having an AMD processor like me, setting `enable_virtualization_extensions = true` will fail, because of the missing nested virtualization support in Windows 10! If this is the case, simply change it to false.

### Start the virtual machine

Now, we can simply start the creating and provisioning of your virtual machine via the console. To start a virtual machine with Vagrant execute this command in the console.

```powershell
vagrant up
```

If you're running this the first time, it should automatically download the box image and ask you to generate an SSH key. Confirm this and continue with this tutorial.

After the machine is booted and ready we can now connect via SSH to the virtual machine.

```powershell
vagrant ssh
```

If you have made changes to the Vagrantfile, you need to stop and reboot the machine again with this command.

```powershell
vagrant reload
```

If you want to delete a virtual machine, simply type this command. Note that this will delete the virtual disks and the config on your hypervisor, but not the Vagrantfile or the folder.

```powershell
vagrant destroy
```

### Explore Vagrant Boxes

Probably, you want to install other Operating Systems like Windows Servers, Windows 10 or also other Linux distributions as well. You can find all those different boxes on the Vagrant box cataloge. Don't forget to filter the results for your desired provider. Otherwise, the results may not work on your hypervisor.

For example, I've also tested the `generic/ubuntu2004` box. This contains an Ubuntu 20.04 LTS image. If you want to create a second virtual machine, simply create a new folder. Note, you don't need to init a new Vagrantfile with the `vagrant init` command. You can also copy the Vagrantfile of your first virtual machine and use this as a template.

If you start the virtual machine, Vagrant will automatically download the box and store this on your computer. That means, you don't need to download the box image again. If you want to check what boxes are currently stored on your computer, use this command.

```powershell
vagrant box list
```

You can also manage boxes, for example remove them to clean up your system with this command.

```powershell
vagrant box remove <your-box-name>
```

### Manage virtual machines with vagrant

Check what virtual machines are currently running with Vagrant using this command. This can be executed from any directory.

```powershell
vagrant global-status
```

This will probably show orphaned records as well. This is because Vagrant is cashing the data and this may not be fully up to date. To clear the cash and remove invalid entries, execute this command

```powershell
vagrant global-status --prune
```
