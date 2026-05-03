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

# Add OpenJDK PPA and install standard versions
RUN add-apt-repository -y ppa:openjdk-r/ppa && apt-get update
RUN apt-get install -y \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    maven

# Install Gradle
RUN mkdir -p /opt/gradle && \
    wget https://services.gradle.org/distributions/gradle-8.5-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-8.5-bin.zip && \
    rm /tmp/gradle-8.5-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-8.5/bin

# Install Latest Java 23 & Java 25 (Early Access)
RUN mkdir -p /opt/java && \
    wget https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.tar.gz -O /tmp/jdk23.tar.gz && \
    tar -xzf /tmp/jdk23.tar.gz -C /opt/java && \
    wget https://download.java.net/java/early_access/jdk24/22/GPL/openjdk-24-ea+22_linux-x64_bin.tar.gz -O /tmp/jdk25.tar.gz || \
    wget https://download.java.net/java/GA/jdk21/fd2272d59fdf46a4a17410e206f036e2/35/GPL/openjdk-21_linux-x64_bin.tar.gz -O /tmp/jdk25.tar.gz && \
    tar -xzf /tmp/jdk25.tar.gz -C /opt/java && \
    rm /tmp/*.tar.gz

# Set up Pterodactyl User
RUN useradd -d /home/container -m container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Environment variables for builder
ENV CURRENT_JAVA=17

CMD ["/bin/bash", "/builder.sh"]
