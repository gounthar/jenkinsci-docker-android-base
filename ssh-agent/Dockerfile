FROM jenkins/ssh-agent:jdk11 as ssh-agent

RUN apt-get update && apt-get install -y curl git

# Now time to install Maven
ARG MAVEN_VERSION=3.8.1
RUN curl -sS -L -O --output-dir /tmp/ --create-dirs  https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar xzf "/tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C /opt/ \
    && rm "/tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && mkdir -p /etc/profile.d \
    && echo "export JAVA_HOME=$JAVA_HOME \n \
             export M2_HOME=/opt/maven \n \
             export PATH=${M2_HOME}/bin:${PATH}" > /etc/profile.d/maven.sh
ENV M2_HOME="/opt/maven"
ENV PATH="${M2_HOME}/bin/:${PATH}"
