# Docker VSCode Python Tutorial // Run your App in a Containerv
Docker VSCode Python Tutorial to run your application inside a Docker Container. I will show you how to set up your development environment with VSCode, which extensions you need and how debugging works.

We will use the free and open-source software VSCode.

Project Homepage: https://code.visualstudio.com

Video: https://youtu.be/jtBVppyfDbE

## Prerequisites

- Linux, macOS or Windows 10, 11 with WSL2 (Debian or Ubuntu) running Docker Desktop

## 1. Installation and Configuration

### 1.1. Add the right VSCode extensions for Python and Docker

There are also some VSCode Extensions, which I highly recommend. You can simply just search for them in VSCode Extensions, download and install them.

- Docker - Makes it easy to create, manage, and debug containerized applications.
- Remote WSL - Open any folder in the Windows Subsystem for Linux (WSL) and take advantage of Visual Studio Code's full feature set.

### 1.2. Connect to WSL2 in VSCode

It's very easy to run VSCode remotely on WSL2. You can just click on the Remote Connection Icon in VSCode, or open VSCode with the "code" command from your Windows Terminal Application. Let's try the second method and create a new project folder for the application and open this remote workspace in VSCode.

If you execute the following commands in the WSL terminal, VSCode should open on your Windows 10 and automatically connect to your remote WSL workspace.

```bash
mkdir ~/vscode-docker-python

code vscode-docker-python
```

*If you're successfully connected to your WSL machine, you'll see it in the bottom statusbar.*

## 2. Build a simple Python application

Finally, we can now start developing our application. This should be the easy part for you. I don't have any good example projects, so we will write a very simple application that will just add two numbers and output the result.

### 2.1. Create a new file and selection our Python interpreter

Let's create a new Python file called `app.py`  and place it in our workspace folder. If you get a message to select your Python Interpreter, you can simply select it. Because we need to tell WSL how we want to run Python programs. If you don't get a message, but you want to select your standard Python interpreter, only for this workspace folder you can create a new file called `.vscode/settings.json` inside your workspace folder.

```py
a = 5
b = 3

c = a + b

print(f"{a} + {b} is {c}")

print("program exited.")
```

### 2.2. Set the Python interpreter

Set the Python interpreter in `.vscode/settings.json`

```json
{
    "python.pythonPath": "/usr/bin/python3"
}
```

### 2.3. Test our Python application without a container

To test and run our application without a container, we can simply execute the following command in the terminal. Or, if you have set up your Python interpreter correctly, you can also run it with F5 in VSCode and debug it.

```bash
python3 app.py
```

## 3. Build our first Docker Container

But of course, we want to deploy this Python application inside a Docker container with VSCode. The Docker extension in VSCode has a pretty comfortable function to generate all necessary files automatically for us. Don't worry I will explain all the things the extension does, so you could also create all these files manually.

### 3.1. Generate Dockerfiles 

To generate all files, press F1 and select "Add Docker Files to Workspace". Simply follow the instructions, add your app.py as your main script and skip Docker-Compose.

### 3.2. How our Docker container is structured

Then, you should see some new files in your workspace folder. Because the Python Docker extension creates a complete environment for you in VSCode. It creates a Dockerfile, a requirements.txt, a .dockerignore, and some .vscode configuration files for you.

- Dockerfile - This is the main file that contains all instructions how to generate and build the Docker image file
- requirements.txt - Includes all necessary libraries and plugins that should be installed inside the Docker image
- .dockerignore - All files that should not be included inside the Docker image
- .vscode/launch.json - How to launch the application, debug it, etc.
- .vscode/tasks.json - Any tasks that should be run by VSCode before the launch tasks

Let's take a closer look at the Dockerfile.

```Dockerfile
# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.8-slim-buster

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "app.py"]
```

### 3.3. Build the Docker image file and run it

The Docker extension in VSCode allows us to simply build the Docker image with a right click on the Dockerfile and select "Build Image".

Open a new Terminal and type docker image list. Because then we can see a new entry called vscodedockerpython (the project folder name). We can also simply run this container and see that our application is running successfully!

## 4. Debugging inside the container

### 4.1. Configure .vscode/launch.json and .vscode/tasks.json.

The Docker extension in VSCode is absolutely beautiful! Because it also allows us to debug our application inside the container with no effort. In the past, I needed to install and use debugging libraries and extensions in Python, but this is not needed anymore. The extension is smart enough to rewrite our entry point file with a debugger automatically.

You simply just need to click on "Start debugging" and it works!

This is only possible, because the Docker extensions created the two files .vscode/launch.json and .vscode/tasks.json.

```json
{
    "configurations": [
        {
            "name": "Docker: Python - General",
            "type": "docker",
            "request": "launch",
            "preLaunchTask": "docker-run: debug",
            "python": {
                "pathMappings": [
                    {
                        "localRoot": "${workspaceFolder}",
                        "remoteRoot": "/app"
                    }
                ],
                "projectType": "general"
            }
        }
    ]
}
```

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "docker-build",
            "label": "docker-build",
            "platform": "python",
            "dockerBuild": {
                "tag": "vscodedockerpython:latest",
                "dockerfile": "${workspaceFolder}/Dockerfile",
                "context": "${workspaceFolder}",
                "pull": true
            }
        },
        {
            "type": "docker-run",
            "label": "docker-run: debug",
            "dependsOn": [
                "docker-build"
            ],
            "python": {
                "file": "app.py"
            }
        }
    ]
}
```

### 4.2. Set breakpoints and analyzing variables

This also supports breakpoints and analyzing variables natively inside the Container! Which is absolutely powerful and key to write complex applications in Python.