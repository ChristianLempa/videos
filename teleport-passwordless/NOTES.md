https://goteleport.com/docs/setup/reference/config/


Generate config file

```
docker run --hostname localhost --rm --platform linux/amd64 --entrypoint=/bin/sh -v /Users/xcad/Projects/videos/teleport-passwordless/config:/etc/teleport -it quay.io/gravitational/teleport:10 -c "teleport configure > /etc/teleport/teleport.yaml"
```