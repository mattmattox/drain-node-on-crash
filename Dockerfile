FROM ubuntu:18.04

MAINTAINER matthew.mattox@rancher.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

## Install kubectl
ADD kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

## Setup run script
WORKDIR /root
ADD run.sh /root/run.sh

CMD /root/run.sh
