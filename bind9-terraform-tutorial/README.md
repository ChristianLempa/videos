# Automate local DNS with Bind and Terraform

Doing manual configuration is a thing of the past! With Terraform, I’m now managing all my local DNS entries fully automatically. In this Tutorial, I’m going to show you exactly how I’ve done that. If you’re new to this, I recommend checking out my other tutorials about Terraform, and [Bind in Docker](../bind9-docker) first.

Video: https://youtu.be/eSUtsDUTzuc


## Prerequisites

- Local DNS Server using Bind9
- Some basic knowledge about Terraform


## Prepare the DNS Server

Usually, Bind9 is configured in static config files, such as the `named.conf`, and the zone config files, that contain all the IP addresses, and hostnames.

To prepare BIND9 to be managed with dynamic updates, you need to generate a TSIG (Transaction Signature) key. It is used to verify the authenticity of DNS messages and prevent unauthorized updates to DNS records.

When using TSIG authentication, the algorithm to use for HMAC. Valid values are `hmac-md5`, `hmac-sha1`, `hmac-sha256` or `hmac-sha512`.

> Although still in common usage, the HMAC-MD5 digest is no longer considered very secure. HMAC-SHA256 is preferred.


### Generate a new TSIG key

To create an HMAC256 TSIG key with the `tsig-keygen` tool, you can use the following command:

```
tsig-keygen -a hmac-sha256
```


### Include the TSIG key in the Bind9 configuration

You can store the HMAC256 TSIG key directly in the `named.conf`, or in a separate file, typically named `tsig.key`, or `named.conf.key` and include it in your BIND configuration using the `include` statement:

```
include "<path-to-tsig.key>";
```

Replace `<path-to-tsig.key>` with the actual path to the `tsig.key` file.

Make sure that the file is readable only by the BIND process and the user running the BIND process, and not readable by other users on the system. This will help to ensure the security of your TSIG key.

### Allow dynamic updates to your DNS zone

When configuring a BIND9 DNS server to allow dynamic updates using a TSIG key, you need to use the ﻿`update-policy` statement in your zone, to specify which keys are allowed to perform updates and which record types they are allowed to update.

```conf
zone "example.com" {
    type master;
    file "example.com.zone";
    update-policy { grant tsig-key zonesub any; };
};
```

### Restart your DNS Server

Restart your DNS Server, to make these changes active.

---
## Manage DNS Records with Terraform

Managing DNS records with Terraform allows you to define your infrastructure as code and automate the process of creating, updating, and deleting DNS records. Terraform is a popular tool for infrastructure as code because it provides a simple and consistent way to manage resources across multiple cloud providers and on-premises infrastructure.

### Set-up the DNS Terraform Provider

First, create a new directory for your Terraform configuration and create a new file named `provider.tf`. In this file, add the following code:

```tf
terraform {

  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.3"
    }
  }

}

provider "dns" {
  update {
    server        = "your-dns-server-ip"
    key_name      = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret    = var.tsig_key
  }
}
```

This code sets up the required provider for the HashiCorp DNS Provider and defines the provider configuration for dynamic updates with a TSIG key. Replace `your-dns-server-ip` with the IP address of your DNS server, and replace `tsig-key.` with the name of your TSIG key.

Next, add the following code to the `provider.tf` file to define a sensitive variable for your TSIG key secret:

```tf
variable "tsig_key" {
  type = string
  sensitive = true
}
```

This code defines a sensitive variable named `tsig_key` of type `string`, which will be used to store the secret value for your TSIG key.

Save the `provider.tf` file and run `terraform init` in your terminal to initialize the provider and download any necessary dependencies.

### Define your DNS resource(s)

Next, define the DNS resource(s) that you want to create or update with dynamic updates, in a new Terraform file, such as `dns.tf`.

This code defines a new `dns_a_record_set` resource named `example` that creates an A record for `example.com`. The `dynamic` block enables dynamic updates for the A record using the TSIG key, and the `update` block specifies the server IP address and TSIG key details.

Note that the `for_each` attribute specifies a variable named `a_records`, which should be defined elsewhere in your Terraform configuration. This variable should be a map of DNS record names to IP addresses, like this:

```tf
variable "a_records" {
  type = map(string)
  default = {
    "server1" = "10.0.0.1"
    "server2" = "10.0.0.2"
  }
}
```

This code defines a map variable named `a_records` that maps the `server1` and `server2` DNS record names to their respective IP addresses.

Save the `dns.tf` file and run `terraform plan` to preview the changes that Terraform will make to your DNS configuration.

### Apply your Terraform configuration

If the preview looks correct, run `terraform apply` to apply your Terraform configuration and create or update your DNS resources with dynamic updates using the TSIG key.

Terraform will prompt you to confirm the changes before applying them. If you're sure that you want to proceed, type `yes` and hit enter.

---
## Apply changes to the static config

### Sync dynamic updates using RNDC

To sync dynamic DNS records to the static configuration in BIND using the `rndc` tool, you can follow these general steps:

Use the `rndc sync` command to synchronize the dynamic updates with the static configuration in BIND. This will update the zone file with the latest DNS records from the dynamic update database.

```
rndc sync example.com
```

Replace `example.com` with the name of the zone that you want to synchronize.

Note that the `rndc sync` command only synchronizes the dynamic updates with the static configuration. It does not apply any changes to the DNS server or reload the configuration.

### Reload the BIND configuration

Use the `rndc reload` command to reload the BIND configuration and apply the changes.

```
rndc reload example.com
```

Replace `example.com` with the name of the zone that you want to reload.

This will reload the BIND configuration and apply any changes that were made to the zone file.

Overall, using the `rndc` tool to sync dynamic DNS records to the static configuration in BIND can help to ensure that your DNS zone files are up-to-date and consistent with the latest DNS records.

---
## References

- [Docs overview | hashicorp/dns | Terraform Registry](https://registry.terraform.io/providers/hashicorp/dns/latest/docs)