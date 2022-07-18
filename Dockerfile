# Taken from https://github.com/openwrt/docker/blob/master/Dockerfile.base
FROM debian

RUN apt-get update -qq && \
    apt-get install -y \
        build-essential \
        ccache \
        clang \
        curl \
        file \
        g++-multilib \
        gawk \
        gcc-multilib \
        gettext \
        git \
        libssl-dev \
        libncurses5-dev \
        locales \
		mc \
        procps \
        pv \
        pwgen \
        python \
        python3 \
        python3-pip \
        rsync \
        signify-openbsd \
        subversion \
        sudo \
        unzip \
        wget \
        zlib1g-dev \
        && apt-get -y autoremove \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -c "OpenWrt Builder" -m -d /home/me -G sudo -s /bin/bash me

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN sed -i 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen
RUN locale-gen

USER me
WORKDIR /home/me
ENV HOME /home/me

#ENTRYPOINT /bin/bash