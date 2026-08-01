# syntax=docker/dockerfile:1

# CrossBridge's host tools require an x86 Linux userspace and a compiler from
# the same era as LLVM 2.9. On ARM hosts, Docker will use amd64 emulation.
FROM --platform=linux/amd64 ubuntu:16.04 AS build-env

ARG DEBIAN_FRONTEND=noninteractive
ARG FLEX_VERSION=4.14.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf automake bison build-essential ca-certificates curl file flex gettext help2man \
        g++-4.8 g++-4.8-multilib gcc-4.8 gcc-4.8-multilib \
        libarchive-dev libexpat1-dev libglib2.0-dev libgmp-dev libmpfr-dev \
        libncurses5-dev libtool libuuid1 libxml2-dev make \
        openjdk-8-jdk-headless perl pkg-config python python-dev rsync texinfo \
        unzip uuid-dev xz-utils zip zlib1g-dev \
    && ln -s x86_64-linux-gnu/asm /usr/include/asm \
    && ln -s /usr/bin/gcc-4.8 /usr/local/bin/gcc \
    && ln -s /usr/bin/g++-4.8 /usr/local/bin/g++ \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://archive.apache.org/dist/flex/${FLEX_VERSION}/binaries/apache-flex-sdk-${FLEX_VERSION}-bin.tar.gz" \
        | tar -xz -C /opt \
    && mv "/opt/apache-flex-sdk-${FLEX_VERSION}-bin" /opt/flex \
    && chmod +x /opt/flex/bin/*

ENV CC=gcc \
    CXX=g++ \
    FLEX_HOME=/opt/flex \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    PATH=/opt/flex/bin:/usr/lib/jvm/java-8-openjdk-amd64/bin:$PATH \
    PLAYERGLOBAL_HOME=/opt/flex/frameworks/libs/player \
    _JAVA_OPTIONS=-Xms256m\ -Xmx6g

FROM build-env AS builder

ARG BUILD_JOBS=2
ARG LIGHTSDK=1

WORKDIR /src
COPY . .

# CrossBridge expects a Player 15 library inside the external Flex SDK. The
# matching library is already distributed in this source tree.
RUN mkdir -p /opt/flex/frameworks/libs/player/15.0 \
    && cp tools/playerglobal/15.0/playerglobal.swc \
        /opt/flex/frameworks/libs/player/15.0/playerglobal.swc \
    && make SHELL=/bin/bash \
        THREADS="${BUILD_JOBS}" LIGHTSDK="${LIGHTSDK}" all

FROM --platform=linux/amd64 ubuntu:16.04 AS crossbridge

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash ca-certificates libc6-i386 lib32gcc1 lib32stdc++6 libgcc1 libstdc++6 \
        libpython2.7 openjdk-8-jre-headless python \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/sdk /opt/crossbridge/sdk
COPY --from=builder /opt/flex /opt/flex
COPY docker/crossbridge-entrypoint.sh /usr/local/bin/crossbridge

ENV AIR_HOME=/opt/flex \
    FLEX_HOME=/opt/flex \
    FLASCC=/opt/crossbridge/sdk \
    FLASCC_ROOT=/opt/crossbridge \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    PATH=/opt/crossbridge/sdk/usr/bin:/opt/flex/bin:/usr/lib/jvm/java-8-openjdk-amd64/bin:$PATH \
    PLAYERGLOBAL_HOME=/opt/flex/frameworks/libs/player

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/crossbridge"]
CMD ["bash"]
