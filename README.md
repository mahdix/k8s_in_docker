# Kubernetes inside Docker

Setup Kubernetes development environment inside a Docker container

This is a Dockerfile which creates a complete Kubernetes development environment. This includes all dependencies (Go, etcd, git, ...) + Kubernetes source code and setting up a non-root user.

To create the docker container, clone this repo and inside repository's root type:
`docker build -t k8s_dev .`
After image is created, you can create your development environment by running: 

`docker run -it k8s_dev`

- If you want a throw-away environment, use `--rm` argument:
`docker run --rm -it k8s_dev`

- If you want to run tests inside the container which needs Docker, you can mount Docker socket and executable to the container:
`docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker k8s_dev`
This will give you ability to create container from within the environment.

Note: This Dockerfile works based on recommended development practice (using fork). If you want to use your own fork, you will need to replace `mahdi` in the Dockerfile with your Github username. Make sure you have already forked Kubernetes repository.
