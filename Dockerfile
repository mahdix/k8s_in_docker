FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8
ENV GOVERSION 1.9
ENV GOPATH /home/mahdi/go

#Install basic modules and Docker
RUN apt-get update && \
    apt-get install -y sudo apt-utils rsync build-essential wget curl git docker.io \
        vim libterm-readline-gnu-perl libterm-readkey-perl iputils-ping && \
    service docker start

#Install Go
RUN cd /usr/local && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz && \
    tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/bin/ && \
    ln -s /usr/local/go/bin/gofmt /usr/bin/ && \
    ln -s /usr/local/go/bin/godoc /usr/bin/ && \
    chmod -R o+w /usr/local/go/pkg && \
    mkdir -p $GOPATH

#Add "mahdi" user
RUN useradd -m mahdi && \
    echo 'mahdi:mahdi' | chpasswd && \
    adduser mahdi sudo && \
    adduser mahdi docker && \
    chown -R mahdi:mahdi /home/mahdi

USER mahdi

#Get Kubernetes source code
RUN whoami && \
    cd /home/mahdi && \
    git clone --depth=1 https://github.com/mahdix/kubernetes.git

#Setup git and dependencies
RUN cd /home/mahdi/kubernetes && \
    git remote rm origin && \
    git remote add origin git@github.com:mahdix/kubernetes.git && \
    git remote add upstream https://github.com/kubernetes/kubernetes.git && \
    git remote set-url --push upstream no_push && \
    hack/install-etcd.sh && \
    go get github.com/onsi/ginkgo/ginkgo && \
    go get github.com/onsi/gomega && \
    go get github.com/golang/glog && \
    go get github.com/cloudflare/cfssl/cmd/cfssl

USER root

RUN ln -s /home/mahdi/kubernetes/third_party/etcd/etcd /usr/local/bin/ && \
    ln -s /home/mahdi/go/bin/ginkgo /usr/local/bin && \
    ln -s /home/mahdi/go/bin/cfssl /usr/local/bin

USER mahdi

EXPOSE 8000-9900
WORKDIR /home/mahdi

