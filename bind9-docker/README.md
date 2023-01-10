# You want a real DNS Server at home? (bind9 + docker)

In this Tutorial, we set up a free and open-source DNS server for your home labs. We will deploy bind9 on an Ubuntu Linux server running Docker and configure it to be an authoritative DNS server in my local network. And we also configure forwarders and access control lists to protect our internal networks. #homeserver #dns #docker

Video: https://github.com/ChristianLempa/videos/tree/main/bind9-docker

---
## Prerequisites

Before you can deploy Bind9 in Docker, you need a Linux Server that has **Docker**, and **Docker-Compose** installed.

For further References, how to use **Docker**, and **Docker-Compose**, check out my previous videos:
- [How to use Docker and migrate your existing Apps to your Linux Server?](https://www.youtube.com/watch?v=y0GGQ2F2tvs)
- [Docker-Compose Tutorial](https://www.youtube.com/watch?v=qH4ZKfwbO8w)

*You can still install Bind9 on a Linux Server that is not running Docker, however, this may require different commands!*

---
## Define your domain

You have multiple options of defining a domain, you can use a so-called "fake-domain", which is not publicly resolvable, such as "your-domain.home". However, a "fake-domain", will not allow you to issue trusted SSL certificates, in this case it makes more sense to use a real "public domain".

### Example of public domain

![[dns-setup-new.excalidraw]]

### Split-horizon DNS

In computer networking, split-horizon DNS (also known as split-view DNS, split-brain DNS, or split DNS) is the facility of a Domain Name System (DNS) implementation to provide different sets of DNS information, usually selected by the source address of the DNS request.

In our example, we can use the internal Bind9 Server to resolve to only internal IPs, while an external DNS Server might resolve to external IPs.

![[dns-split-horizon.excalidraw]]

---
## Install Bind9 in Docker

### Prepare Ubuntu Server

Edit the config file of systemd-resolved, `/etc/systemd/resolved.conf`.

Uncomment the line `DNSStubListener`, and set it to **no**.

```conf
[Resolve]
...
DNSStubListener=no
...
```

Restart the sytemd-resolved service using `sudo systemctl restart systemd-resolved`.

### Create Docker-Compose file

Copy the example `docker-compose.yml` file in your project directory, and make sure you replace the `container_name` value with your desired container name.

**Example `docker-compose.yml`:**

```yaml
version: "3"

services:
  bind9:
    container_name: dns-demo-2
    image: ubuntu/bind9:latest
    environment:
      - BIND9_USER=root
      - TZ=Europe/Berlin
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - .config:/etc/bind
      - .cache:/var/cache/bind
      - .records:/var/lib/bind
    restart: unless-stopped
```

### Create the main config file

Copy the example `named.conf` file in the `./config/` folder of your project directory, and make sure you replace the values, with your desired configuration.

**Example `named.conf`:**

```conf
acl internal {
  192.168.0.0/24;
};

options {
  forwarders {
    1.1.1.1;
    1.0.0.1;
  };
  allow-query { internal; };
};

zone "demo.clcreative.de" IN {
  type master;
  file "/etc/bind/demo-clcreative-de.zone";
};
```

### Prepare the zone file

Copy the example `demo-clcreative-de.zone` file in the `./config/` folder of your project directory, and make sure you replace the values, with your desired configuration.

**Example `demo-clcreative-de.zone`:**

```conf
$TTL 2d

$ORIGIN demo.clcreative.de.

@             IN     SOA    ns.demo.clcreative.de. info.clcreative.de (
                            2022121900     ; serial
                            12h            ; refresh
                            15m            ; retry
                            3w             ; expire
                            2h )           ; minimum TTL

              IN     NS     ns.demo.clcreative.de.

ns            IN     A      10.20.3.4

srv-demo-2    IN     A      10.20.3.4
*.srv-demo-2  IN     A      10.20.3.4
```

### Add your DNS Records

According to the following examples, you can add additional DNS Records, defined in the [IANA's DNS Resource Records TYPEs](https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4).


### Start the container

To start the container, execute the following command in the project directory.

```sh
docker-compose up -d
```

---
## Test Bind9

To test your bind9 dns server, you can use the "nslookup" command on your local machine, followed by the IP address of your dns server.

```sh
nslookup name-to-resolve.tld your-dns-server-ip
```

---
## DNS Lookup Chain

![[dns-lookup-chain-optimized.excalidraw]]

---
## References

- [Bind9 Configuration and Zone Files](https://bind9.readthedocs.io/en/v9_18_10/chapter3.html)
- [IANA's DNS Resource Records TYPEs](https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4)
