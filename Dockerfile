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
ENV ANDROID_HOME "/opt/android"
ENV ANDROID_SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
# Finish Android

# Start  NodeJS
ENV PATH $PATH:/opt/node/bin
# Finish NodeJS

# Start Cordova
ENV CORDOVA_VERSION latest
ENV IONIC_VERSION latest
# Finish Cordova

RUN echo "${uApt}"

RUN set -x \
    # ------------------------------------------------------
    # Start  Android
    && dpkg --add-architecture i386 \
    # Finish Android
    && eval "${aptUpdate}" \
    # ------------------------------------------------------
    # Start  Java 
    && eval "${aptInstall} apt-utils software-properties-common" \
        >/dev/null 2>&1 \ 
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && eval "${aptUpdate}" \
    && eval "${aptInstall} openjdk-8-jdk" \
        >/dev/null 2>&1 \ 
    && java -version
    # Finish Java
    # ------------------------------------------------------
    # Start  Android
RUN eval "${aptInstall} ant curl libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 net-tools zlib1g:i386 wget unzip" \
        >/dev/null 2>&1 \ 
    && mkdir -p /opt \
    && wget -q "${ANDROID_SDK_URL}" -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d "${ANDROID_HOME}" \
        >/dev/null 2>&1 \ 
    && rm android-sdk-tools.zip \
    && yes | sdkmanager --licenses \
        >/dev/null 2>&1 \ 
    && touch /root/.android/repositories.cfg \
    && sdkmanager "emulator" "tools" "platform-tools" \
        >/dev/null 2>&1 \ 
    && yes | sdkmanager --update --channel=3 \
        >/dev/null 2>&1 \ 
    && yes | sdkmanager \
        "platforms;android-29" \
        "platforms;android-28" \
        "platforms;android-27" \
        "platforms;android-26" \
        "platforms;android-25" \
        "platforms;android-24" \
        "platforms;android-23" \
        "platforms;android-22" \
        "platforms;android-21" \
        "platforms;android-19" \
        "platforms;android-17" \
        "platforms;android-15" \
        "build-tools;29.0.2" \
        "build-tools;29.0.1" \
        "build-tools;29.0.0" \
        "build-tools;28.0.3" \
        "build-tools;28.0.2" \
        "build-tools;28.0.1" \
        "build-tools;28.0.0" \
        "build-tools;27.0.3" \
        "build-tools;27.0.2" \
        "build-tools;27.0.1" \
        "build-tools;27.0.0" \
        "build-tools;26.0.2" \
        "build-tools;26.0.1" \
        "build-tools;25.0.3" \
        "build-tools;24.0.3" \
        "build-tools;23.0.3" \
        "build-tools;22.0.1" \
        "build-tools;21.1.2" \
        "build-tools;19.1.0" \
        "build-tools;17.0.0" \
        "system-images;android-29;google_apis;x86" \
        "system-images;android-28;google_apis;x86" \
        "system-images;android-26;google_apis;x86" \
        "system-images;android-25;google_apis;armeabi-v7a" \
        "system-images;android-24;default;armeabi-v7a" \
        "system-images;android-22;default;armeabi-v7a" \
        "system-images;android-19;default;armeabi-v7a" \
        "extras;android;m2repository" \
        "extras;google;m2repository" \
        "extras;google;google_play_services" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
        "add-ons;addon-google_apis-google-23" \
        "add-ons;addon-google_apis-google-22" \
        "add-ons;addon-google_apis-google-21" \
        >/dev/null 2>&1 \ 
    # ------------------------------------------------------
    # Gradle 
    && eval "${aptInstall} gradle" \
        >/dev/null 2>&1 \ 
    && gradle --version \
    # ------------------------------------------------------
    #Maven
    && eval "${aptPurge} maven maven2" \
    && eval "${aptInstall} maven" \
        >/dev/null 2>&1 \ 
    && mvn --version \
    # Finish Android
    # ------------------------------------------------------
    # Start  NodeJS
    && eval "${aptInstall} curl git ca-certificates" \
        >/dev/null 2>&1 \ 
    && mkdir -p /opt/node \
    && (cd /opt/node \
        && curl -sSL https://nodejs.org/dist/latest/ | grep "node-" | head -1 | sed -e 's/^[^-]*-\([^-]*\)-.*/\1/' > /tmp/nodejsVersion \
        && curl -sSL https://nodejs.org/dist/$(cat /tmp/nodejsVersion)/node-$(cat /tmp/nodejsVersion)-linux-x64.tar.gz | tar xz --strip-components=1) \
    && node --version \
    && npm --version \
    # Finish NodeJS
    # ------------------------------------------------------
    # Start Cordova
    && (cd /tmp \
        && npm i -g --unsafe-perm "cordova@${CORDOVA_VERSION}" "ionic@${IONIC_VERSION}") \
    && cordova --version \
    && ionic --version \
    # Finish Cordova
    # ------------------------------------------------------
    # Clean up
    &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && eval "${aptAutoremove}" \
    && eval "${aptClean}" 
