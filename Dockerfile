FROM ubuntu:22.04

LABEL author="Antigravity" maintainer="dapaupau@sigaul.com"

ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    openssl \
    git \
    tar \
    sqlite3 \
    fontconfig \
    tzdata \
    iproute2 \
    libfreetype6 \
    unzip \
    wget \
    gnupg2 \
    software-properties-common

# Install Java standard versions from official Ubuntu repos
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    maven

# Install Gradle
RUN mkdir -p /opt/gradle && \
    wget https://services.gradle.org/distributions/gradle-8.5-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-8.5-bin.zip && \
    rm /tmp/gradle-8.5-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-8.5/bin

# Install Latest Java 21, 23 & Java 25 from Adoptium (Temurin)
RUN mkdir -p /opt/java && \
    curl -L "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk" -o /tmp/jdk21.tar.gz && \
    mkdir -p /opt/java/jdk-21 && tar -xzf /tmp/jdk21.tar.gz -C /opt/java/jdk-21 --strip-components=1 && \
    curl -L "https://api.adoptium.net/v3/binary/latest/23/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk" -o /tmp/jdk23.tar.gz && \
    mkdir -p /opt/java/jdk-23 && tar -xzf /tmp/jdk23.tar.gz -C /opt/java/jdk-23 --strip-components=1 && \
    curl -L "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk" -o /tmp/jdk25.tar.gz && \
    mkdir -p /opt/java/jdk-25 && tar -xzf /tmp/jdk25.tar.gz -C /opt/java/jdk-25 --strip-components=1 && \
    rm /tmp/*.tar.gz

# Set up Pterodactyl User
RUN useradd -d /home/container -m container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Environment variables for builder
ENV CURRENT_JAVA=17

CMD ["/bin/bash", "/builder.sh"]
