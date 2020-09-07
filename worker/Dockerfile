FROM ubuntu:18.04

MAINTAINER matthew.mattox@rancher.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    docker-ce-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

## Install kubectl
ADD kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
#RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && chmod u+x kubectl && mv kubectl /usr/local/bin/kubectl

## Setup run script
WORKDIR /root
ADD run.sh /root/run.sh

CMD /root/run.sh
