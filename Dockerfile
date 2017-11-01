FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG C
ENV GOVERSION 1.9
ENV GOPATH /home/mahdi/go

#Install basic modules
RUN apt-get update && \
    apt-get install -y sudo apt-utils rsync build-essential wget curl git \
        libterm-readline-gnu-perl libterm-readkey-perl iputils-ping net-tools \
    add-apt-repository ppa:pkg-vim/vim-daily && \
    apt-get update && \
    apt-get install vim


#Install latest docker
RUN curl -fsSL get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    service docker start && \
    systemctl enable docker

#Install Go
RUN cd /usr/local && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz && \
    tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/bin/ && \
    ln -s /usr/local/go/bin/gofmt /usr/bin/ && \
    ln -s /usr/local/go/bin/godoc /usr/bin/ && \
    chmod -R o+w /usr/local/go/pkg && \
    mkdir -p $GOPATH

#Add and setup "mahdi" user
RUN useradd -m mahdi && \
    echo 'mahdi:mahdi' | chpasswd && \
    adduser mahdi sudo && \
    adduser mahdi docker && \
    chown -R mahdi:mahdi /home/mahdi

USER mahdi

#Get source code, note that this expects a shared directory containing git private ke
RUN cd /home/mahdi && \
    git clone --depth=1 https://github.com/mahdix/kubernetes.git && \
    git clone --depth=1 https://github.com/mahdix/minikube.git 

#Setup git and dependencies
RUN cd /home/mahdi/kubernetes && \
    git remote set-url origin git@github.com:mahdix/kubernetes.git && \
    git remote add upstream https://github.com/kubernetes/kubernetes.git && \
    git remote set-url --push upstream no_push && \
    cd /home/mahdi/minikube && \
    git remote set-url origin git@github.com:mahdix/minikube.git && \
    git remote add upstream https://github.com/kubernetes/minikube.git && \
    git remote set-url --push upstream no_push

#Setup etcd and other required modules
RUN cd /home/mahdi/kubernetes && \
    hack/install-etcd.sh && \
    go get github.com/onsi/ginkgo/ginkgo && \
    go get github.com/onsi/gomega && \
    go get github.com/golang/glog && \
    go get github.com/cloudflare/cfssl/cmd/cfssl

#Setup symlinks
RUN mkdir /home/mahdi/bin && \
    ln -s /home/mahdi/kubernetes/third_party/etcd/etcd /home/mahdi/bin/ && \
    ln -s /home/mahdi/go/bin /home/mahdi/bin/gobin

USER mahdi

EXPOSE 6000-8900
WORKDIR /home/mahdi

