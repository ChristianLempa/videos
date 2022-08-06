https://goteleport.com/docs/setup/reference/config/


## Preq

- A Linux server running Ubuntu and Docker, Docker-compose installed
- You must have a valid domain and an FQDN that should match the `public_addr` in the teleport.yml config file
- The ports 3023, 3024, 3025 and 443 needs to be accessible on the server

## Instructions

1. Generate config file
```
docker run --hostname localhost --rm --platform linux/amd64 --entrypoint=/bin/sh -v /Users/xcad/Projects/videos/teleport-passwordless/config:/etc/teleport -it quay.io/gravitational/teleport:10 -c "teleport configure > /etc/teleport/teleport.yaml"
```
2. Modify the following fields in the config
```
teleport:
  nodename: <your-servername>
auth_service:
  cluster_name: <your-servers-fqnd>
proxy_service:
  web_listen_addr: 0.0.0.0:443
  public_addr: <your-servers-fqdn>:443
  acme:
    enabled: yes
    email: <your-email-address>
```
3. Upload files to server
```
scp -r * <servername>:/home/xcad/teleport-passwordless
```
4. Check permissions of the directory, they should match the `user: uid:gid` in the compose file
5. Start Teleport, check that certs have been created successfully
```
docker-compose up
```
6. Create user
```
docker exec -it teleport tctl users add xcad --roles=editor --logins=root,xcad
```
7. Create password
