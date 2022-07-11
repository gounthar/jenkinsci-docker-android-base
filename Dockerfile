# Version 2.0.0
FROM jenkins/ssh-agent:jdk11 as ssh-agent
MAINTAINER gounthar <16569+gounthar@users.noreply.github.com>

COPY conf/openSSL/openssl-1.1.1k.conf /etc/ld.so.conf.d/

# ## Create shared cache dirs and apt installupdate
RUN mkdir -p /user-cache /shared-cache/{m2,npm,sonar,yarn} /shared-cache/m2/repository && apt update && \
# Install Development Tools needed for NDK and so on
# The current applications available with the CentOS Development tools apt installgroup are:
# bison, byacc, cscope, ctags, cvs, diffstat, doxygen, flex, gcc, gcc-c++, gcc-gfortran, gettext, git, indent, intltool, libtool, patch, patchutils, rcs, redhat-rpm-config, rpm-build, subversion, swig, systemtap
apt install -y build-essential wget curl zlib1g-dev openssl
# Install java (OpenJDK)
RUN apt install -y debianutils && which java
# Install 32bit Library
# maybe not necessary apt install -y glibc.i686 glibc-dev.i686 zlib-dev.i686 ncurses-dev.i686 libX11-dev.i686 libXrender.i686 zip unzip && \
# Install expect, python-pip and python-wheel
RUN apt install -y python3-pip && pip3 -V && \
apt install -y expect sudo && \
# apt install -y install libstdc++6:i386 expect python-pip python-wheel sudo && \
# Install flutter dependencies
#apt install -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm && \
# procps (ps) is needed by homebrew
apt install -y procps git unzip xz-utils zip libglu1-mesa && \
# Clean up
apt-get clean && \
# was "pip < 21.0" but got "Could not find a version that satisfies the requirement pip3<21.0 (from versions: )"
rm -rf /var/cache/apt install/var/log/* /tmp/* && pip3 install --upgrade pip && pip3 install requests

# sudo
ADD /sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers

################################################################################
## android:developer (uid 102, gid 100) is the only valid user for using shared cache #
################################################################################
USER root

# RUN groupadd -r developer && useradd -m -d /home/android/ -s /bin/bash --no-log-init -r -g developer android
# Because of #12 0.558 [error] character map file `UTF-8' not found: No such file or directory
RUN apt install -y locales && \
       localedef -i en_US -f UTF-8 en_US.UTF-8
#    && groupmod -g 18000006 users \
#    && usermod -u 102 android \
#    && groupmod -g 100 developer \
#    && chown -R android:developer /home/android \
#    && chown -R android:developer /user-cache \
    ## cache dir for build toolings
#    && chown -R android:developer /shared-cache

# Eliminate Warning -->  /root/.android/repositories.cfg not found!
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg

# Install Android SDK
# See https://stackoverflow.com/questions/60440509/android-command-line-tools-sdkmanager-always-shows-warning-could-not-create-se
ENV JAVA_HOME /opt/java/openjdk/
# Used to be /usr/lib/jvm/java-11-openjdk
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV CMDLINE_TOOLS_HOME $ANDROID_HOME/cmdline-tools
ENV PATH /usr/local/bin:$PATH:CMDLINE_TOOLS_HOME/tools/bin
RUN mkdir -p /usr/local/android-sdk-linux/cmdline-tools/latest && cd /usr/local/android-sdk-linux && \
 curl -L -O  https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip && \
 unzip -qq commandlinetools-linux-7302050_latest.zip -d tmp && mv tmp/cmdline-tools/* cmdline-tools/latest && \
 rm -rf /usr/local/android-sdk-linux/commandlinetools-linux-6858069_latest.zip && \
 yes|/usr/local/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --licenses && \
 /usr/local/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --update && \
 /usr/local/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --list && \
 /usr/local/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "platform-tools" \
                                                      "ndk;23.1.7779620" \
                                                      "extras;google;m2repository" \
                                                      "extras;android;m2repository" \
                                                      "platforms;android-32" \
                                                      "build-tools;32.0.0" \
                                                      "add-ons;addon-google_apis-google-24" \
                                                      "add-ons;addon-google_apis-google-23" 2>&1 >/dev/null && \
 chown -R jenkins:jenkins $ANDROID_HOME && ls -artl /usr/local/android-sdk-linux

# Install Spoon
# Source: https://oss.sonatype.org/service/local/repositories/snapshots/content/com/squareup/spoon/spoon-runner/2.0.0-SNAPSHOT/spoon-runner-2.0.0-20180516.161323-46-all.jar
ENV SPOON_HOME /usr/local/spoon-2.0
RUN mkdir -p $SPOON_HOME 
ADD dependencies/spoon-runner-2.0.0.jar $SPOON_HOME/
ADD scripts/spoon-runner.sh $SPOON_HOME/
RUN cd $SPOON_HOME && chmod 755 spoon-runner-2.0.0.jar && chmod 755 spoon-runner.sh

# Install OpenSTF script
ENV OPEN_STF_HOME /usr/local/openstf
RUN mkdir -p /usr/local/openstf && mkdir -p /home/android/.android/adbkey && chown -R android:developer /home/android/.android/adbkey && \
    chmod 644 /home/android/.android/adbkey && chmod -R 777 /home/android/.android
ADD scripts/android-stf-api.py /usr/local/openstf
RUN chmod 755 /usr/local/openstf/android-stf-api.py
 
# Install ADB keys for OpenSTF
ADD conf/adb/adbkey.txt /home/android/.android/adbkey
ADD conf/adb/adbkey.pub /home/android/.android/adbkey.pub

# Install apk analyser script
ADD scripts/apkanalyser.sh /usr/local/apkanalyser/apkanalyser.sh
ENV APK_ANALYSER_HOME /usr/local/apkanalyser
RUN chmod 755 $APK_ANALYSER_HOME/apkanalyser.sh
 
# Install Apache-Ant
RUN cd /usr/local/ && \
 curl -L -O https://mirroir.wptheme.fr/apache//ant/binaries/apache-ant-1.10.12-bin.tar.gz && \
 tar xf apache-ant-1.10.12-bin.tar.gz && \
 rm -rf /usr/local/apache-ant-1.10.12-bin.tar.gz

# Install Maven
RUN cd /usr/local/ && \
 curl -L -O https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz && \
 tar xf apache-maven-3.8.1-bin.tar.gz && \
 rm -rf /usr/local/apache-maven-3.8.1-bin.tar.gz

# Install Gradle
RUN cd /usr/local/bin && \
 curl -L -O https://downloads.gradle-dn.com/distributions/gradle-6.7.1-bin.zip && \
  unzip -o -qq gradle-6.7.1-bin.zip && \
  rm -rf /usr/local/bin/gradle-6.7.1-bin.zip

# Install Infer
ENV INFER_VERSION 1.1.0
RUN curl -sSL "https://github.com/facebook/infer/releases/download/v$INFER_VERSION/infer-linux64-v$INFER_VERSION.tar.xz" \
    | tar -C /opt -xJ && \
    ln -s "/opt/infer-linux64-v$INFER_VERSION/bin/infer" /usr/local/bin/infer

# Install Flutter
RUN cd /opt && git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/opt/flutter/bin"
RUN flutter doctor

# Install Dependency Check
# TODO

# Install Homebrew in the hope of installing rbenv and then fastlane
# #32 0.386 Insufficient permissions to install Homebrew to "/home/linuxbrew/.linuxbrew".
# USER android
WORKDIR /home/android
ENV PATH "$PATH:/home/android/.linuxbrew/bin"
# fails with a "bash: line 147: USER: unbound variable" error RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
RUN USER=android /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Damn, same error
# Line 147, the script calls ${USER}. Let's try to export this variable
RUN export USER=android && echo $USER && \
    /home/linuxbrew/.linuxbrew/bin/brew shellenv >> /home/android/.bashrc && \
# There's a bug with xorg formulae cf https://github.com/Homebrew/linuxbrew-core/issues/387 \
# && brew tap linuxbrew/xorg
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) && brew install fastlane && brew install firebase-cli && \
#  brew install curl && \
# Some users are getting this error Error loading plugin 'fastlane-plugin-firebase_app_distribution': You don't have write permissions for the /home/android/.linuxbrew/Cellar/fastlane/2.148.1/libexec directory.
  sudo chmod -R 777 /home/linuxbrew/.linuxbrew/ && find / -name firebase && firebase

USER android
# MAVEN CONFIG (Cache support & proxy)
ADD ["./conf/mvn/settings.xml", "/home/android/.m2/settings.xml"]
ADD ["./conf/mvn/settings-security.xml", "/home/android/.m2/settings-security.xml"]

# PROXY CONFIG
ENV OPENSTF_URL 192.168.0.86
ENV no_proxy "127.0.0.1, localhost, $OPENSTF_URL"
ENV NO_PROXY "127.0.0.1, localhost, $OPENSTF_URL"

# ENVIRONMENT CONFIG
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV ANDROID_NDK_HOME /usr/local/android-ndk-r21

ENV GRADLE_HOME /usr/local/bin/gradle-6.7.1
ENV GRADLE_OPTS -Dandroid.builder.sdkDownload=true
ENV GRADLE_USER_HOME /shared-cache/gradle

ENV MAVEN_HOME /usr/local/apache-maven-3.8.1
ENV M2_HOME=/shared-cache/m2
ENV ANT_HOME /usr/local/apache-ant-1.10.12
ADD ["./conf/sonar/sonar-secret.txt", "/root/.sonar/sonar-secret.txt"]
# Put .sonar/cache in /shared-cache
ENV SONAR_USER_HOME=/shared-cache/sonar/

# Specify the www and the workdir :
USER www
WORKDIR /home/android

# PATH CONFIG
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin
ENV PATH $PATH:$ANDROID_HOME/bin
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$GRADLE_HOME/bin
ENV PATH $PATH:$MAVEN_HOME/bin
ENV PATH $PATH:$ANT_HOME/bin
ENV PATH $PATH:$SPOON_HOME
ENV PATH $PATH:$APP_GARDEN_HOME
ENV PATH $PATH:$OPEN_STF_HOME
ENV PATH $PATH:$APK_ANALYSER_HOME
ENV PATH $PATH:/home/android/.linuxbrew/lib/ruby/gems/2.5.0/bin
ENV HOMEBREW_PREFIX "/home/android/.linuxbrew"
ENV HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
ENV HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
# ENV PATH $HOMEBREW_PREFIX/bin:/home/android/.linuxbrew/sbin${PATH+:$PATH}
# ENV MANPATH $HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:
# ENV INFOPATH $HOMEBREW_PREFIX/share/info${INFOPATH+:$INFOPATH}
# fastlane requires some environment variables set up to run correctly.
# In particular, having your locale not set to a UTF-8 locale will cause issues
# with building and uploading your build.
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
# .bash_profile should be read
CMD ["bash", "-l -c"]

# Nah, forget it, it's not read. So we're using this trick
ENV BASH_ENV "/home/android/.bashrc"
# Check container health by running a command inside the container
HEALTHCHECK CMD /usr/local/android-sdk-linux/tools/bin/sdkmanager
