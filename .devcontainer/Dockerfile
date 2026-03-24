FROM mcr.microsoft.com/devcontainers/base:noble

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl git unzip wget ca-certificates apt-transport-https gnupg2 software-properties-common

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    git \
    unzip \
    wget \
    ca-certificates \
    apt-transport-https \
    gnupg2 \
    software-properties-common \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    openjdk-17-jdk \
    adb \
    libxdo-dev \
    jq \
    zip \
    xz-utils \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    patchelf \
    libfuse2 \
    file \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*