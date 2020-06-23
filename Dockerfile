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
ENV nullEnd " >/dev/null 2>&1"
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
ENV PHONEGAP_VERSION latest
ENV IONIC_VERSION latest
ENV FRAMEWORK_SEVEN_VERSION latest
# Finish Cordova

# Use this to truncate long RUN s
# # \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#     && true
# RUN    set -x \
#     && source "$HOME/.sdkman/bin/sdkman-init.sh" \
# # /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

# ------------------------------------------------------
# PRE-REQUISITES
RUN    rm /bin/sh && ln -s /bin/bash /bin/sh
# RUN    set -x \
RUN    true \
    && eval "dpkg --add-architecture i386 ${nullEnd}" \
    && eval "${aptUpdate}" \
# ------------------------------------------------------
# SDKMAN
    && eval "${aptInstall} curl wget unzip zip ca-certificates ${nullEnd}" \
    && curl -s "https://get.sdkman.io" | bash \
    && source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && sdk version \
# ------------------------------------------------------
# JAVA
    && sdk install java $(sdk ls java | grep "\-open" | grep -v "\.ea\." | sed -e 's/^.*| \([^-]*\)-.*$/\1/' | grep "^8" | head -1)-open \
    && eval "echo \"JAVA_HOME=${JAVA_HOME}\"" \
    && java -version \
# ------------------------------------------------------
# ANT
    && sdk install ant \
    && ant -version \
# ------------------------------------------------------
# MAVEN
    && sdk install maven \
    && mvn -version \
# ------------------------------------------------------
# GRADLE
    && sdk install gradle \
    && gradle --version \
# ------------------------------------------------------
# ANDROID
    && eval "${aptInstall} curl libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 net-tools zlib1g:i386 wget unzip zipalign ${nullEnd}" \
    && mkdir -p /opt \
    && wget -q "${ANDROID_SDK_URL}" -O android-sdk-tools.zip \
    && eval "unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} ${nullEnd}" \
    && rm android-sdk-tools.zip \
    && eval "(yes | sdkmanager --licenses) ${nullEnd}" \
    && touch /root/.android/repositories.cfg \
    && eval "sdkmanager emulator tools platform-tools ${nullEnd}" \
    && eval "(yes | sdkmanager --update --channel=3)  ${nullEnd}" \
    && yes | sdkmanager \
    "platforms;android-29" \
    "platforms;android-28" \
    "build-tools;29.0.3" \
    #"system-images;android-29;google_apis;x86" \
    #"system-images;android-28;google_apis;x86" \
    #"system-images;android-26;google_apis;x86" \
    #"system-images;android-25;google_apis;armeabi-v7a" \
    #"system-images;android-24;default;armeabi-v7a" \
    #"system-images;android-22;default;armeabi-v7a" \
    #"system-images;android-19;default;armeabi-v7a" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    #"extras;google;google_play_services" \
    #"extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    #"extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    #"add-ons;addon-google_apis-google-23" \
    #"add-ons;addon-google_apis-google-22" \
    #"add-ons;addon-google_apis-google-21" \
    >/dev/null 2>&1 \
# ------------------------------------------------------
# NODEJS
    && eval "${aptInstall} curl git ca-certificates ${nullEnd}" \
    && mkdir -p /opt/node \
    && (cd /opt/node \
        && curl -sSL https://nodejs.org/dist/latest/ | grep "node-" | head -1 | sed -e 's/^[^-]*-\([^-]*\)-.*/\1/' > /tmp/nodejsVersion \
        && curl -sSL https://nodejs.org/dist/$(cat /tmp/nodejsVersion)/node-$(cat /tmp/nodejsVersion)-linux-x64.tar.gz | tar xz --strip-components=1) \
    && node --version \
    && npm --version \
# ------------------------------------------------------
# CORDOVA PHONEGAP IONIC FRAMEWORK7 cordova-check-plugins
    && (cd /tmp \
        && npm i -g --unsafe-perm=true --allow-root "cordova@${CORDOVA_VERSION}" "phonegap@${PHONEGAP_VERSION}" "@ionic/cli@${IONIC_VERSION}" "framework7-cli@${FRAMEWORK_SEVEN_VERSION}" "cordova-check-plugins") \
    && cordova --version \
    && cordova telemetry off \
    && phonegap --version \
    && phonegap analytics off \
    && ionic --version \
    && framework7 --version \
    && cordova-check-plugins --version \
# ------------------------------------------------------
# CLEAN-UP
    && eval "${aptAutoremove}" \
    && eval "${aptClean}" \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# ------------------------------------------------------
# LAST LINE ...
    && true
