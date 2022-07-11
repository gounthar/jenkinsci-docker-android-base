# Version 2.0.0
FROM jenkins/ssh-agent:jdk11 as ssh-agent
MAINTAINER gounthar <16569+gounthar@users.noreply.github.com>

RUN apt update && apt install -y git
# Checkout Infer
RUN mkdir -p /home/jenkins/infer && cd /home/jenkins/infer && \
    git clone https://github.com/facebook/infer.git
# Compile Infer
RUN apt-get install -y bash curl libc6-dev \
                       openjdk-11-jdk-headless \
                       sqlite3 \
                       xz-utils \
                       zlib1g-dev
RUN cd /home/jenkins/infer/infer && ls -artl && chmod +x build-infer.sh
# && ./build-infer.sh java
# install Infer system-wide...
# RUN make install