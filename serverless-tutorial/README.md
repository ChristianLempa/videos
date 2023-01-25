# I made a YouTube Bot in Python! (Serverless Computing: DigitalOcean Functions)

In this video, I explain what serverless computing is, by showing how I've used DigitalOcean Functions, to write a simple YouTube Bot in Python. This Bot is getting the latest published video on a YouTube Channel, and sends out a message to a Discord Channel. We discuss how to use APIs, store and retrieve Secrets, Tokens, use S3 Buckets, and much more. There is a lot of coding stuff in here, hope you'll enjoy it! #serverless #python #digitaloceanfunctions

Video: https://www.youtube.com/watch?v=D_MUphj5tCM


---
## Prerequisites

Before you can create serverless functions in **DigitalOcean**, you need to sign up.

*Some examples that get information about the latest video of a YouTube channel, need to use the YouTube Data API. The YouTube Data API allows you to retrieve information about YouTube videos, channels, playlists, and more. To use the API, you'll need to have a project on the Google Cloud Platform, and you'll need to enable the YouTube Data API for that project.*

---
## Deploy a web function

### Create a namespace

Log in to your **DigitalOcean** Account and in the web UI, create a new **namespace** in the **manage -> functions** section.

### Create a function

In the **namespace** section, you can create a new **function** under **actions -> create function**.

Select your desired **runtime**, e.g. `Python`, `NodeJS`, etc. In this tutorial I'm using `Python` You can also add your function to a **package**, which is optional. Make sure the **web function** checkbox is enabled.

In the code editor, you can add your desired code or modify the example.

### Run the function

To run the function from the web ui, you can click on **run**, this will simulate a web request to the function. You can also change the **parameters**, which is optional.

You can also run the function from your PC by opening a web request.

```sh
curl $(doctl sls fn get your-package/your-function --url)
```

### Authentication

To require a secret to run your function, you can edit the function settings it in the **settings -> access & security -> web function** menu. 

Enable the checkbox **secure web function**, and add a custom secret, or use the generated one.

Test the authentication with the following command.

```sh
curl -X GET $(doctl sls fn get your-package/your-function --url) \
     -H "Content-Type: application/json" \
     -H "X-Require-Whisk-Auth: your-secret"
```

---
## Develop functions in vscode

### Install doctl

Install `doctl` following the directions for your package manager or operating system, e.g. macOS:

```sh
brew install doctl
```

### Install serverless support

Install the support for serverless functions in **doctl**.

```sh
doctl serverless install
```

### Connect to your namespace

Connect to your **namespace**, you have created before.

```sh
doctl serverless connect your-namespace
```

### Initialize a new project

You can initialize a new project by executing the following command.

```sh
doctl serverless init your-namespace --language python
```

You can now open the **namespace** project directory in a tool like **VSCode** and start developing your **packages** and **functions**.

### Edit the project file

All project settings of a **namespace** , **packages**, and **functions** are described in a `project.yml` file.

```yaml
packages:
    - name: your-package
      functions:
        - name: your-function
          runtime: python:default
          web: false
```

### Edit packages and functions

All **packages** need to be created in a separate folder e.g. `packages/`.  All **functions** are created by adding files in the package folders.

A project structure should look like this.

```text
namespace/project
 ↳ packages
    ↳ your-package-1
        ↳ your-function-1.py
        ↳ your-function-2.py
    ↳ your-package-1
        ↳ your-function-3.py
 ↳ .gitignore
 ↳ project.yml
```

### Deploy the package

Upload the **package** code to DigitalOcean.

```sh
doctl serverless deploy your-package
```

### Invoke a function

You can test and run a non-web function with the following command.

```sh
doctl serverless functions invoke your-package/your-function
```

### Invoke a function with parameters

You can invoke **functions** with optional or required parameters.

```sh
doctl serverless functions invoke httpreq-demo-1/hello -p name:Christian
```

In the code, you can read parameters like the following.

```py
def main(args):
    name = args.get("name", "stranger")
    greeting = "Hello " + name + "!"
    print(greeting)
    return {"body": greeting}
```

### Environment Variables

You can add environment variables by updating your `project.yml` like the following.

```yml
...
packages:
    - name: httpreq-demo-1
      functions:
        - name: hello
          binary: false
          main: ""
          runtime: python:default
          web: false
          websecure: false
          parameters: {}
          environment: {
            PERSON: "Christian"
          }

```

In the code, you can refer to the environment variables like the following.

```py
import os


def read_env_variable(variable_name):
    try:
        return os.environ.get(variable_name)
    except Exception:
        return False


def main(args):
    greeting = f"Hello {read_env_variable('PERSON')}"
    print(greeting)
    return {"body": greeting}
```

---
## Troubleshooting

### Build requirements

You can add other Python Libraries by adding a `requirements.txt` and a `build.sh` script into your project.

Change your **project** structure according to the following.

```text
namespace/project
 ↳ packages
    ↳ your-package-1
        ↳ your-function-1
	        ↳ __main__.py
	        ↳ build.sh
	        ↳ requirements.txt
```

**Example `requirements.txt`:**
```sh
google-api-python-client==2.72.0
```

**Example `build.sh`:**
```sh
#!/bin/bash

set -e

virtualenv virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt
deactivate
```

### Increase Limits

When you get timeout errors, try increasing the function **limits**.

```yaml
...
packages:
    - name: your-package
      functions:
        - name: your-function
          ...
		  limits:
            timeout: 3000  # timeout in seconds
            memory: 512  # memory in mb
```

---
## References

- [DigitalOcean Functions Docs](https://docs.digitalocean.com/products/functions/) 