# https://github.com/openwrt/buildbot/blob/master/docker/buildworker/Dockerfile

FROM	debian:13
MAINTAINER	Entware team

ARG	DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y \
	build-essential \
	ccache \
	clang \
	curl \
	gawk \
	g++-multilib \
	gcc-multilib \
	genisoimage \
	git-core \
	gnupg \
	gosu \
	libdw-dev \
	libelf-dev \
	libncurses-dev \
	libssl-dev \
	locales \
	mc \
	pv \
	pwgen \
	python3 \
	python3-venv \
	python3-pip \
	python3-pyelftools \
	python3-cryptography \
	qemu-utils \
	rsync \
	signify-openbsd \
	shfmt \
	subversion \
	sudo \
	swig \
	unzip \
	wget \
	zstd && \
    apt-get clean && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install -U pip
RUN pip3 install \
	pyelftools \
	pyOpenSSL \
	service_identity \
	legacy-cgi

ENV LANG=en_US.utf8

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -c "OpenWrt Builder" -m -d /home/me -G sudo -s /bin/bash me

USER me
WORKDIR /home/me
ENV HOME /home/me

#ENTRYPOINT /bin/bash
