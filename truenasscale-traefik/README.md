# WIP
WIP

Project Homepage: https://www.truenas.com/

Video: // WIP

---
## Prerequisites

TrueNAS Scale with TrueCharts

For further References, how to deploy **TrueNAS Scale** with **TrueCharts**, check out my previous video:
- [TrueNAS Scale the ULTIMATE Home Server? Docker, Kubernetes, Apps](https://youtu.be/LJY9KBbL4j0)

---
## Setting up an ip address

When using Traefik on TrueNAS Scale, it can be useful to add an alias ip address, that will be used as the primary ip address for kubernetes load balancers.

IP Addresses are managed under **Network -> Interfaces**. 

### Add an alias ip address to the primary interface

Under **IP Addresses**, add an **Alias**.

## Setting up certificates

When using Traefik, you should issue trusted SSL certificates to be used by the load balancers. This can be a **wildcard** certificate, that is valid for all subdomains and all future applications, you want to expose.

Both, ACME, and self-sigend certficiates will work.

Certificates are managed under **Credentials -> Certificates**.

### Option 1: Add a new self-signed certificate (WIP)

Under **Certificates**, add a **Certificate**.

1. Select **Import Certificate**.
2. Upload your **Certificiate**, and **Private Key**.

### Option 2: Issue a new certificate via ACME (WIP)

Under **ACME DNS-Authenticators**, add a **DNS Authenticator**.

1. Select your DNS Provider
2. Add your DNS Provider's Credentials, such as Email, API Key, API Secret, or API Token

Under **Certificate Signing Requests**, add a **Certificate Signing Request**.

1. Select Certificate Signing Request
2. Choose your Certificate Options (RSA, or EC)
3. Enter your Certificate Subject Details
4. Enter your Subject Alternative Names according to your domain, you can also add a wilcard in here (`*.local`, or `*.domain.tld`).

## Install Traefik

### WIP

## Deploy a test application

### WIP

---
## References

- [WIP](url)
