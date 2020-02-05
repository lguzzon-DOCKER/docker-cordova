# Tools
# https://github.com/hadolint/hadolint
# https://www.dockerfilelint.com/#/
# https://github.com/jessfraz/dockfmt

FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm


# Start  Java 
ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

LABEL maintainer="Maik Hummel <hi@beevelop.com>" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_VERSION \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0.0-rc1" \
  org.label-schema.vcs-url="https://github.com/beevelop/docker-java.git" \
  org.label-schema.name="beevelop/java" \
  org.label-schema.vendor="Beevelop" \
  org.label-schema.description="Simple Java Docker image (used as base image)" \
  org.label-schema.url="https://beevelop.com/"

# required to use add-apt-repository
RUN buildDeps='software-properties-common'; \
  set -x && \
  apt-get update && apt-get install -y $buildDeps --no-install-recommends && \
  add-apt-repository ppa:openjdk-r/ppa -y && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends openjdk-8-jdk && \
  java -version && \

  # Clean up
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  apt-get autoremove -y && \
  apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
# Finish Java


# Start  Android
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANDROID_BUILD_TOOLS_VERSION=27.0.0 \
    ANDROID_APIS="android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends wget curl maven ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 && \

    # Installs Android SDK
    mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \

    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean
# Finish Android

# Start  NodeJS

ENV NODEJS_VERSION=latest \
    PATH=$PATH:/opt/node/bin

WORKDIR "/opt/node"

RUN apt-get update && apt-get install -y curl git ca-certificates --no-install-recommends && \
    curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 && \

    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean
# Finish NodeJS

# Start Cordova
ENV CORDOVA_VERSION=latest

WORKDIR "/tmp"

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}
# Finish Cordova
