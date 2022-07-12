# Self-Signed Certificates in Kubernetes
 
## Steps

1. Create a Certificate Authority
    a. Create a CA private key
    ```bash
    openssl genrsa -out ca.key 4096
    ```
    b. Create a CA certificate
    ```bash
    openssl req -new -x509 -sha256 -days 365 -key ca.key -out ca.crt
    ```
    c. Import the CA certificate in the `trusted Root Ca store` of your clients
2. Convert the content of the key and crt to base64 oneline
    ```bash
    cat ca.crt | base64 -w 0
    cat ca.key | base64 -w 0
    ```
3. Create a secret object `nginx1-ca-secret.yml` and put in the key and crt content
4. Create a cluster issuer object `nginx1-clusterissuer.yml`
5. Create a new certificate `nginx1-cert.yml` for your projects
6. Add a `tls` reference in your ingress `nginx1-ingress.yml`
7. Apply all changes

## Architecture Diagram

```
                Cert-Manager Objects                        Nginx1 Objects

               ┌───────────────────────┐                    ┌─────────────────────────────────┐
Created CA     │ kind: Secret          │                    │                                 │
private key ──►│ name: nginx1-ca-secret│◄─────────┐         │ kind: Ingress                   │
and cert       │ tls.key: **priv key** │          │         │ name: nginx1-ingress            │
               │ tls.crt: **cert**     │          │         │ tls:                            │
               └───────────────────────┘          │         │   - hosts:                      │
                                                  │         │     - nginx1.clcreative.home    │
               ┌──────────────────────────────┐   │    ┌────┼───secretName: nginx1-tls-secret │
               │                              │   │    │    │                                 │
               │ kind: ClusterIssuer          │   │    │    └─────────────────────────────────┘
           ┌───┤►name: nginx1-clusterissuer   │   │    │
           │   │ secretName: nginx1-ca-secret─┼───┘    │
           │   │                              │        │
           │   └──────────────────────────────┘        │
           │                                           │
           │   ┌───────────────────────────────┐       │
           │   │                               │       │
           │   │ kind: Certificate             │       │
           │   │ name: nginx1-cert             │       │
           └───┼─issuerRef:                    │       │
               │   name: nginx1-clusterissuer  │       │
               │   kind: ClusterIssuer         │       │
               │ dnsNames:                     │       │
               │   - nginx1.clcreative.home    │       │
           ┌───┼─secretName: nginx1-tls-secret │       │
           │   │                               │       │
           │   └──────────┬────────────────────┘       │
           │              │                            │
           │              │ will be created            │
           │              ▼ and managed automatically  │
           │   ┌───────────────────────────────┐       │
           │   │                               │       │
           │   │ kind: Secret                  │       │
           └───┤►name: nginx1-tls-secret◄──────┼───────┘
               │                               │
               └───────────────────────────────┘
```

