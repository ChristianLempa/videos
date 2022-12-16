# Secure HTTPS for all your TrueNAS Scale Apps (traefik)

In this Tutorial we install Traefik, a free and open-source load balancer, on TrueNAS Scale. We will cover the creation of trusted SSL Certificates via Letsencrypt and Cloudflare DNS, and also how to securely expose an application like Homeassistant. #TrueNAS #Traefik #HomeLab

Project Homepage: https://www.truenas.com/

Video: https://youtu.be/QSMgfz5zrxo

---
## Prerequisites

TrueNAS Scale with TrueCharts

For further References, how to deploy **TrueNAS Scale** with **TrueCharts**, check out my previous video:
- [TrueNAS Scale the ULTIMATE Home Server? Docker, Kubernetes, Apps](https://youtu.be/LJY9KBbL4j0)
- [How to create a valid self signed SSL Certificate?](https://youtu.be/VH4gXcvkmOY)

---
## Setting up an ip address

When using Traefik on TrueNAS Scale, it can be useful to add an alias ip address, hence the ports `80`, and `443` are already used by the default truenas scale web ui. Your alias ip can be used as the primary ip address for kubernetes load balancers to use port `80`, and `443` for Traefik.

IP Addresses are managed under **Network -> Interfaces**. 

### Add an alias ip address to the primary interface

Under **IP Addresses**, add an **Alias**.

### Change kubernetes ip address

Under **Apps -> Settings -> Advanced Settings**, change the **Node IP** to your alias ip address.

All future load balancers deployed in Kubernetes will use this new **Node IP**.

### Change the TrueNAS Scale GUI listening ip addresses

Under **System Settings -> General -> GUI -> Settings**, change the **Web Interface IPv4 Address** to include only IP addresses where the GUI should be listening on. *Exclude the alias IP address, you used for the Node IP in the App Settings.*

## Setting up certificates

When using Traefik, you should issue trusted SSL certificates to be used by the load balancers. This can be a **wildcard** certificate, that is valid for all subdomains and all future applications, you want to expose.

Both, ACME, and self-sigend certficiates will work.

Certificates are managed under **Credentials -> Certificates**.

### Option 1: Add a new self-signed certificate

Under **Certificates**, add a **Certificate**.

1. Select **Import Certificate**.
2. Upload your **Certificiate**, and **Private Key**.

### Option 2: Issue a new certificate via ACME

Under **ACME DNS-Authenticators**, add a **DNS Authenticator**.

1. Select your DNS Provider
2. Add your DNS Provider's Credentials, such as Email, API Key, API Secret, or API Token

Under **Certificate Signing Requests**, add a **Certificate Signing Request**.

1. Select Certificate Signing Request
2. Choose your Certificate Options (RSA, or EC)
3. Enter your Certificate Subject Details
4. Enter your Subject Alternative Names according to your hostname, and domain.
5. (Optional) you can also add a wilcard in here (`*.local`, or `*.domain.tld`), ***but don't soley use a wildcard!***

Under **Certificate Signing Requests**, select your **Certificate Signing Request** and create an **ACME Certificate**.

1. Accept **Terms of Service** and chose your **Renew Certificate Days**.
2. Select **Production**, or **Staging** in **ACME Server Directory URI**.
3. Add your **Domain**, and select your **Authenticator**.

## Install Traefik

Applications are managed under **Apps -> Available Applications**. 

*This tutorial needs additional TrueNAS Scale Charts from the Community Repo TrueCharts. Follow the instructions described on the official website of [TrueCharts ](https://truecharts.org), to add the Community Repo to your TrueNAS Scale Charts.* 

### Deploy Traefik as a new application

1. Create a new application using the Traefik TrueCharts Deployment.
2. Select your **desired replicas**, and the correct **timezone**.
3. Enable **ingressClass**, and **isDefaultClass**.
4. (Optional) change the **Main Entrypoints**, **Service Type** to **ClusterIP** to protect the web interface of Traefik.
5. Change the **web Entrypoints**, **Entrypoint Port** to `80`.
6. Change the **websecure Entrypoints**, **Entrypoint Port** to `443`.
7. (Optional) change other settings according to your environment.

## Deploy a test application

Applications are managed under **Apps -> Available Applications**. 

*Make sure, you have a dns record that's pointing to the primary node ip address of your TrueNAS Scale server, as described above.*

### Deploy homeassistant as a test

1. Create a new application using the Homeassistant TrueCharts Deployment.
2. In the **Network and Service** Settings, change the **Service Type** to `ClusterIP`.
3. In the **Ingress** Settings, enable **Ingress**.
4. In the **Ingress** Settings, add your desired **Hostname**, and **Paths**.
5. In the **Ingress** Settings, configure your desired **TLS Settings**, and the corresponding **Hostname**, and select the created **TrueNAS Scale Certifcate**.

Check if you can reach your app.

---
## References

- [TrueCharts ](https://truecharts.org)
