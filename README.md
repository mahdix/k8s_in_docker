# Kubernetes inside Docker

Setup Kubernetes development environment inside a Docker container

This is a Dockerfile which creates a complete Kubernetes development environment. This includes all dependencies (Go, etcd, git, ...) + Kubernetes source code and setting up a non-root user.

To create the docker container, clone this repo and inside repository's root type:
`docker build -t k8s_dev .`
After image is created, you can create your development environment by running: 

`docker run --privileged -v /var/lib/docker -it k8s_dev`

- If you want a throw-away environment, use `--rm` argument:
`docker run --privileged -v /var/lib/docker --rm -it k8s_dev`

This will give you ability to create container from within the environment.

