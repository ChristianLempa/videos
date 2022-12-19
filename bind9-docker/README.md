# You want a real DNS Server at home? (bind9 + docker)
WIP

Video: // WIP

---
## Prerequisites

Before you can deploy Bind9 in Docker, you need a Linux Server that has **Docker**, and **Docker-Compose** installed.

For further References, how to use **Docker**, and **Docker-Compose**, check out my previous videos:
- [How to use Docker and migrate your existing Apps to your Linux Server?](https://www.youtube.com/watch?v=y0GGQ2F2tvs)
- [Docker-Compose Tutorial](https://www.youtube.com/watch?v=qH4ZKfwbO8w)

*You can still install Bind9 on a Linux Server that is not running Docker, however, this may require different commands!*

---
## Prepare Ubuntu Server

... port 53 needs to be free

### Edit systemd-resolved config file

Edit the config file of systemd-resolved, `/etc/systemd/resolved.conf`.

Uncomment the line `DNSStubListener`, and set it to **no**.

```conf
[Resolve]
...
DNSStubListener=no
...
```

### Restart the systemd-resolved service

Restart the sytemd-resolved service using `sudo systemctl restart systemd-resolved`.

## Deploy bind9

### Prepare the compose file

...

### Prepare the named config file

...

### Prepare the zone file

...

### Start bind9

...

## Reverse Lookup

### WIP

...

---
## References

