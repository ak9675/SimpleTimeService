# SimpleTimeService - Particle41 DevOps Team Challenge

This repository contains the _SimpleTimeService_ microservice, developed as part of the Particle41 DevOps Team Challenge. Its primary purpose is to demonstrate familiarity with minimalist application development, Docker containerization, and adherence to container best practices, along with comprehensive documentation.

**Project Purpose**
The _SimpleTimeService_ is a lightweight web application designed to return the current timestamp and the IP address of the client accessing it.

**Application Details**
The application is written in Python using the Flask micro-framework and is served by Gunicorn for production readiness.
When accessed at its root URL (/), it provides a JSON response in the following format:

`{
  "timestamp": "<current date and time>",
  "ip": "<the IP address of the visitor>"
}`

Example Response:

`{
  "timestamp": "2025-06-21T10:30:00.123456Z",
  "ip": "192.168.1.100"
}`

**Getting Started**
Follow these instructions to set up, build, and run the _SimpleTimeService_ container.

**Prerequisites**
Before you begin, ensure you have the following tools installed on your system:

**Git:**

*Used for cloning this repository.

*Installation Guide git docs https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

**Docker:**

*Used for building the container image and running the container.

*Installation Guide for Docker Docs https://docs.docker.com/get-docker/

**Docker Hub Account (Optional, for publishing):**

*A free account is required if you wish to publish the image to a public container registry.

*Sign up for Docker Hub at https://hub.docker.com/signup

**1. Clone the Repository**

First, clone this Git repository to your local machine:

`git clone [https://github.com/](https://github.com/)<your-username>/simple-time-service.git`

`cd simple-time-service`

Replace _<your-username>_ with your actual GitHub (or other Git platform) username and repository name if different.

**2. Build the Docker Image**

Navigate into the cloned directory (if you haven't already) and build the Docker image. 
The _docker build_ command will use the _Dockerfile_ in the current directory to create an image named _simple-time-service_.

_Ensure you are in the directory containing Dockerfile, app.py, and requirements.txt_
`docker build -t simple-time-service .`

_-t simple-time-service:_ Tags the image with the name simple-time-service. You can choose any name, but this is a good convention.

_.:_ Specifies the build context (the current directory), where Docker will look for the Dockerfile and other files.

Upon successful completion, you should see a message indicating the image has been built, and you can verify its presence:

`docker images simple-time-service`

**3. Run the Docker Container**

Now that the image is built, you can run the container. The docker run command will create and start a container from your image, mapping a host port to the container's exposed port (8080).

`docker run -d -p 8080:8080 --name simple-time-service-container simple-time-service`

_-d_: Runs the container in detached mode (in the background).

_-p 8080:8080_: Maps port 8080 on your host machine to port 8080 inside the container. This means you can access the application via http://localhost:8080.

_--name simple-time-service-container_: Assigns a human-readable name to your container, making it easier to manage.

_simple-time-service_: The name of the Docker image to run.

You can check if the container is running:

`docker ps`

**4. Test the Application**

Once the container is running, open your web browser or use _curl_ to access the application:

`curl http://localhost:8080`

You should see a JSON response similar to this:

`{"ip": "172.17.0.1", "timestamp": "2025-06-21T10:30:00.123456Z"}`

(Note: The _ip_ will be the Docker internal IP for the container when accessed from the host, or the client's public IP if accessed via a public endpoint later.)

**5. Stop and Remove the Container (Optional)**

To stop and remove the running container:

`docker stop simple-time-service-container`

`docker rm simple-time-service-container`

**6. Publish the Image to Docker Hub (Optional)**

If you need to publish your image to a public registry like Docker Hub, follow these steps:

_**Log in to Docker Hub:**_

`docker login`

Enter your Docker Hub username and password when prompted.

_**Tag the Image:**_

You need to tag your local image with your Docker Hub username and the desired repository name.
Replace _<your-dockerhub-username>_ with your actual Docker Hub username.

`docker tag simple-time-service <your-dockerhub-username>/simple-time-service:latest`

_**Push the Image:**_

Now, push the tagged image to Docker Hub.

`docker push <your-dockerhub-username>/simple-time-service:latest`

You can then find your image on Docker Hub at https://hub.docker.com/repositories

**Container Best Practices & Code Quality**

Small Image Size: The _Dockerfile_ uses_ python:3.9-slim-bust_er as a base image, which is a lightweight distribution, contributing to a smaller final image size. _pip install --no-cache-dir_ also helps.

Non-Root User: The application runs as a non-root user (_pythonuser_) inside the container. This is a crucial security practice that limits potential damage if the application is compromised.

Gunicorn for Production: The application is served by Gunicorn, a production-ready WSGI HTTP server, instead of Flask's built-in development server.
