FROM golang

RUN apt-get update && \
    apt-get install -y sudo apt-utils rsync locales && \
    locale-gen en_US.UTF-8 && \
    useradd -M docker && \
    echo 'docker:docker' | chpasswd && \
    adduser docker sudo && \
    mkdir /home/docker &&  \
    chown -R docker:docker /home/docker && \
    cd /usr/local/bin && \
    ln -s ../go/bin/go && \
    ln -s ../go/bin/gofmt && \
    chmod -R o+w /usr/local/go/pkg

USER docker

RUN whoami && \
    cd /home/docker && \
    git clone https://github.com/mahdix/kubernetes.git

RUN cd /home/docker/kubernetes && \
    git remote rm origin && \
    git remote add origin git@github.com:mahdix/kubernetes.git && \
    git remote add upstream https://github.com/kubernetes/kubernetes.git && \
    git remote set-url --push upstream no_push && \
    git checkout master && \
    make WHAT=cmd/kubectl && \
    hack/install-etcd.sh && \
    echo export PATH="\$PATH:$(pwd)/third_party/etcd" >> ~/.profile

EXPOSE 8000-9900
WORKDIR /home/docker

