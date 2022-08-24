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

provider "civo" {
  token = var.civo_token
  region = "FRA1"
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_key =  var.cloudflare_api_key
}

data "cloudflare_zone" "clcreative" {
  name = "clcreative.de"
}

data "civo_size" "medium" {
  filter {
    key = "name"
    values = ["g3.small"]
    match_by = "re"
  }
}

data "civo_disk_image" "ubuntu" {
  filter {
    key = "name"
    values = ["ubuntu-focal"]
  }
}

data "civo_disk_image" "xcad-ssh" {
  # ...
}

resource "cloudflare_record" "dns_teleport-demo" {
  zone_id = data.cloudflare_zone.clcreative.id
  name = "teleport-demo.clcreative.de"
  # value =  
  type = "A"
  proxied = false
}

resource "civo_instance" "foo" {
  # example
  #
  # hostname = "foo.com"
  # tags = ["python", "nginx"]
  # notes = "this is a note for the server"
  # size = element(data.civo_instances_size.small.sizes, 0).name
  # disk_image = element(data.civo_disk_image.debian.diskimages, 0).id
}