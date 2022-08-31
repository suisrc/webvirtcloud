FROM debian:bullseye-slim

LABEL maintainer="suisrc@outlook.com"

EXPOSE 80
EXPOSE 6080

ARG SRV_HOME=/srv
ARG S6_RELEASE=v3.1.2.1

# linux and softs
RUN apt-get update -qqy \
    && DEBIAN_FRONTEND=noninteractive apt-get -qyy install \
    --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    ntpdate \
    locales \
    git \
    python3-venv \
    python3-dev \
    python3-lxml \
    libvirt-dev \
    zlib1g-dev \
    nginx \
    pkg-config \
    gcc \
    libldap2-dev \
    libssl-dev \
    libsasl2-dev \
    libsasl2-modules \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 
# =============================================================================================
# s6-overlay
RUN S6_RURL="https://github.com/just-containers/s6-overlay/releases" &&\
    S6_APP="${S6_RURL}/download/${S6_RELEASE}/s6-overlay-x86_64.tar.xz" &&\
    S6_CFG="${S6_RURL}/download/${S6_RELEASE}/s6-overlay-noarch.tar.xz" &&\
    curl -o /tmp/s6-cfg.tar.xz -L "${S6_CFG}" && tar -C / -Jxpf /tmp/s6-cfg.tar.xz &&\
    curl -o /tmp/s6-app.tar.xz -L "${S6_APP}" && tar -C / -Jxpf /tmp/s6-app.tar.xz &&\
    rm -rf  /tmp/*
    #tar xzf /tmp/s6.tar.gz -C / --exclude='./bin' && tar xzf /tmp/s6.tar.gz -C /usr ./bin

ENTRYPOINT ["/init"]
# =============================================================================================
# webvirtcolud
WORKDIR /srv/webvirtcloud

# Creating the user and usergroup
# ARG USERNAME=www-data
# RUN groupadd --gid 1001 $USERNAME && \
#     useradd  --uid 1001 --gid $USERNAME -m -s /bin/bash $USERNAME   && \
#     echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
#     chmod 0440 /etc/sudoers.d/$USERNAME && chmod g+rw /home

RUN mkdir -p /srv/webvirtcloud && \
    curl -fSL --compressed https://github.com/suisrc/webvirtcloud/archive/refs/tags/v0.0.1.tar.gz | \
    tar -xz -C /srv/webvirtcloud --strip-components=1 && \
    chown -R www-data:www-data /srv/webvirtcloud

# Setup webvirtcloud
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip3 install -U pip && \
    pip3 install wheel && \
    pip3 install -r conf/requirements.txt && \
    pip3 cache purge && \
    chown -R www-data:www-data /srv/webvirtcloud

RUN . venv/bin/activate && \
    python3 manage.py migrate && \
    python3 manage.py collectstatic --noinput && \
    chown -R www-data:www-data /srv/webvirtcloud

# Setup Nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN  chown -R www-data:www-data /var/lib/nginx &&\
     cp conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/

# Register services to runit
RUN mkdir /etc/services.d/nginx && \
    mkdir /etc/services.d/webvirt && \
    mkdir /etc/services.d/novnc && \
    echo '#!/bin/sh\nnginx -g "daemon off;"' /etc/services.d/nginx/run && \
    cp conf/runit/webvirtcloud.sh /etc/services.d/webvirt/run && \
    cp conf/runit/novncd.sh /etc/services.d/novnc/run



