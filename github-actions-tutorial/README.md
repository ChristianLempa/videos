# Using GitHub Actions, in a Homelab?

DESCRIPTION, HASHTAGS

Video: VIDEOLINK

---
## Prerequisites

TODO: Before you can xyz, you need to abc.

---
## Set up an organization in GitHub

Go to your GitHub Account under **Settings -> Access -> Organization**, and create a new organization.

Open the organization settings.

To create a new runner, go to **Code, planning, and automation -> Actions -> Runners**, and add a new self-hosted runner.

![](../_assets/github-actions-tutorial-asset-1.png)

---
## Install GitHub Runner locally on Linux

Download and extract the GitHub Runner code into your project folder.

```sh
curl -o actions-runner-osx-x64-2.303.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.303.0/actions-runner-osx-x64-2.303.0.tar.gz

tar xzf ./actions-runner-osx-x64-2.303.0.tar.gz
```

Configure and Start the GitHub Runner.

```sh
./config.sh --url https://github.com/clcreative --token your-token

./run.sh
```

Install Runner as a service.

```shell
sudo ./svc.sh install

sudo ./svc.sh start
```

---
## Create a new project

Create a new `yml` file into the `.github/workflows` folder.

**Example:**
```yml
name: Deploy to Kubernetes
on:
  push:
    branches:
      - main

env:
  KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}

jobs:
  deploy:
    runs-on: "self-hosted"  # (optional) name of the runner labels, groups
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

	 # (...)
```

Add a new `KUBE_CONFIG` secret in the GitHub project.

---
## Deploy a Kubernetes Application

Add your desired Kubernetes **Manifests** into the `kubernetes/` project folder.

Add new jobs to apply your **Manifests** via GitHub Actions.

**Examples:**
```yml

# (...)
      - name: Deploy App(Deployment)
        uses: actions-hub/kubectl@master
        with:
          args: apply -f kubernetes/deployment.yml
          
      - name: Deploy Service
        uses: actions-hub/kubectl@master
        with:
          args: apply -f kubernetes/service.yml
          
      - name: Deploy Ingress
        uses: actions-hub/kubectl@master
        with:
          args: apply -f kubernetes/ingress.yml

```

---
## References

- [GitHub Actions Documentation - GitHub Docs](https://docs.github.com/en/actions)
