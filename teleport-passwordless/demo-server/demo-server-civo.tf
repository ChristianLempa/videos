terraform {
  backend "remote" {
    organization = "clcreative"
    workspaces {
      name = "videos-teleport-passwordless"
    }
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.22.0"
    }
    civo = {
      source = "civo/civo"
      version = "~> 1.0.21"
    }
  }
}

# ---

provider "civo" {
  token = var.civo_token
  region = "FRA1"
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_key =  var.cloudflare_api_key
}

# ---

variable "civo_token" {
    type = string
    sensitive = true
}

variable "cloudflare_email" {
    type = string
}

variable "cloudflare_api_key" {
    type = string
    sensitive = true
}

# ---

data "cloudflare_zone" "clcreative" {
  name = "clcreative.de"
}

data "civo_size" "small" {
  filter {
    key = "name"
    values = ["g3.small"]
    match_by = "re"
  }
}

data "civo_disk_image" "ubuntu" {
  filter {
    key = "name"
    values = ["ubuntu-jammy"]
  }
}

data "civo_ssh_key" "ssh_xcad" {
  name = "xcad"
}

# ---

resource "civo_instance" "srv_teleport-demo" {
  hostname = "teleport-demo.clcreative.de"
  notes = "This is a demo server for the teleport-passwordless video."
  size = element(data.civo_size.small.sizes, 0).name
  disk_image = element(data.civo_disk_image.ubuntu.diskimages, 0).id
  initial_user = "xcad"
  sshkey_id = data.civo_ssh_key.ssh_xcad.id
}

# ---

resource "cloudflare_record" "dns_teleport-demo" {
  zone_id = data.cloudflare_zone.clcreative.id
  name = "teleport-demo.clcreative.de"
  value = civo_instance.srv_teleport-demo.public_ip
  type = "A"
  proxied = false
}