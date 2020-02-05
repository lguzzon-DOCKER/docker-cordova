# Tools
# https://github.com/hadolint/hadolint
# https://www.dockerfilelint.com/#/
# https://github.com/jessfraz/dockfmt

FROM ubuntu:bionic

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

LABEL maintainer="Luca Guzzon <luca.guzzon@gmail.com>" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.version=$BUILD_VERSION \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.schema-version="1.0.0-rc1" \
    org.label-schema.vcs-url="https://github.com/lguzzon-DOCKER/docker-cordova.git" \
    org.label-schema.name="lguzzon-DOCKER/docker-cordova" \
    org.label-schema.vendor="SolonSoft" \
    org.label-schema.description="[Ubuntu -> Java -> Android -> NodeJS -> Cordova] Docker image" \
    org.label-schema.url="https://github.com/lguzzon-DOCKER/docker-cordova"

# Start  Base 
ENV DEBIAN_FRONTEND noninteractive
ENV uAptGet "apt-get -y -qq -o Dpkg::Options::=--force-all"
ENV uApt "${uAptGet}"
ENV aptInstall "${uApt} --no-install-recommends install"
ENV aptPurge "${uApt} purge"
ENV aptAutoremove "${uApt} autoremove"
ENV aptClean "${uApt} clean && ${uApt} autoclean"
ENV aptUpdate "${aptAutoremove} && ${uApt} --fix-missing update"
ENV TERM xterm
# Finish Base

    # Start  Android
ENV ANDROID_SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV ANDROID_BUILD_TOOLS_VERSION 27.0.0
ENV ANDROID_APIS "android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26"
ENV ANT_HOME "/usr/share/ant"
ENV MAVEN_HOME "/usr/share/maven"
ENV GRADLE_HOME "/usr/share/gradle"
ENV ANDROID_HOME "/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin \
    # Finish Android

    # Start  Java 
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
    # Finish Java

    # Start  NodeJS
ENV PATH $PATH:/opt/node/bin
    # Finish NodeJS

    # Start Cordova
ENV CORDOVA_VERSION latest
    # Finish Cordova

RUN echo "${uApt}"

RUN set -x \
    # Start  Android
    && dpkg --add-architecture i386 \
    # Finish Android
    && eval "${aptUpdate}" \
    
    # Start  Java 
    && eval "${aptInstall} software-properties-common" \ 
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && eval "${aptUpdate}" \ 
    && eval "${aptInstall} openjdk-11-jdk" \
    && java -version
    # Finish Java

    # Start  Android
RUN eval "${aptInstall} wget curl maven ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386" \
    && mkdir -p /opt \
    && (cd /opt \
        && mkdir android \
        && cd android \
        && wget -O tools.zip ${ANDROID_SDK_URL} \
        && unzip tools.zip \
        && rm tools.zip \
        && echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} \
        && chmod a+x -R $ANDROID_HOME \
        && chown -R root:root $ANDROID_HOME) \
    # Finish Android
    
    # Start  NodeJS
RUN eval "${aptInstall} curl git ca-certificates" \
    && mkdir -p /opt/node \
    && (cd /opt/node \
        && curl -sSL https://nodejs.org/dist/latest/ | grep "node-" | head -1 | sed -e 's/^[^-]*-\([^-]*\)-.*/\1/' > /tmp/nodejsVersion \
        && curl -sSL https://nodejs.org/dist/$(cat /tmp/nodejsVersion)/node-$(cat /tmp/nodejsVersion)-linux-x64.tar.gz | tar xz --strip-components=1) \
    && node --version \
    && npm --version \
    # Finish NodeJS
    
    # Start Cordova
    && (cd /tmp \
        && npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}) \
    # Finish Cordova
    
    # Clean up
    &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && eval "${aptAutoremove}" \ 
    && eval "${aptClean}" 
