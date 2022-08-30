# How to manage multiple Hosts in Portainer
Portainer Remote Host Management with a proper TLS protected Docker API. Learn how to easily and securely expose the Docker API on a remote server and connect your Portainer main instance for remote server management.

We will use the free and open-source software Portainer.


Project Homepage: 
Documentation: 

Video: https://youtu.be/kKDoPohpiNk

## Prerequisites

- Running Portainer

## 1. Generate Certificates for Portainer and the Remote Server

### 1.1. Create a Certificate Authority (CA)

```bash
openssl genrsa -aes256 -out ca-key.pem 4096

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```

### 1.2. Generate a Server Certificate

```bash
openssl genrsa -out server-key.pem 4096

openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = DNS:$HOST,IP:$INTERNALIP1,IP:$INTERNALIP2 >> extfile.cnf

echo extendedKeyUsage = serverAuth >> extfile.cnf

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

### 1.3. Generate a Client Certificate

```bash
openssl genrsa -out key.pem 4096

openssl req -subj '/CN=$PORTAINERDNS' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth > extfile-client.cnf

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```

### 1.4. Cleanup and Protect your Private Keys!

```bash
rm -v client.csr server.csr extfile.cnf extfile-client.cnf

chmod -v 0400 ca-key.pem key.pem server-key.pem
```

### 1.5. Enable Docker API on your Remote Server

Create `/etc/docker/daemon.json` with the following settings and replace `$INTERNALIP` with your IP address of the remote server.

```json
{
    "hosts": ["unix:///var/run/docker.sock", "tcp://$INTERNALIP:2376"],
    "tls": true,
    "tlscacert": "/root/certs/ca.pem",
    "tlscert": "/root/certs/server-cert.pem",
    "tlskey": "/root/certs/server-key.pem",
    "tlsverify": true
}
```

Also Create a file in `/etc/systemd/system/docker.service.d/docker.conf`.

```conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
```

Reload your daemon settings `systemctl daemon-reload` and restart your Docker daemon with `sudo service docker restart`.

## 2. Add the Endpoint in Portainer

On the Portainer Web UI you now need to import the Certs and setup the connection.

And then you should see that Portainer now has another endpoint successfully connected. And we now can manage our remote server from our main portainer instance, just like the local server.