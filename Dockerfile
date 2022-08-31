FROM debian:bullseye-slim

LABEL maintainer="suisrc@outlook.com"

EXPOSE 80

# linux and softs
RUN apt-get -qq update \
    #&& apt-get upgrade -y \
    && apt-get install -y \
        curl \
        sudo \
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
        supervisor \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download webvirtcloud
RUN mkdir -p /srv/webvirtcloud && \
    curl -fSL --compressed https://github.com/suisrc/webvirtcloud/archive/refs/tags/v0.0.1.tar.gz | \
    tar -xz -C /srv/webvirtcloud --strip-components=1 && \
    rm -Rf webvirtcloud/doc/ && \
    chown -R www-data:www-data /srv/webvirtcloud

# step webvirtcloud
WORKDIR /srv/webvirtcloud
# Setup webvirtcloud
COPY nginx.conf /etc/nginx/nginx.conf
COPY *.sh /srv/webvirtcloud

RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip3 install -U pip && \
    pip3 install wheel && \
    pip3 install -r conf/requirements.txt && \
    pip3 cache purge && \
    chown -R www-data:www-data /srv/webvirtcloud &&\
    chown -R www-data:www-data /var/lib/nginx &&\
    cp conf/supervisor/*.conf /etc/supervisor/conf.d/ &&\
    cp conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/ &&\
    cp conf/nginx/debian_nginx.conf /etc/nginx/nginx.conf.bak &&\
    chmod +x start.sh && chmod +x startinit.sh


CMD ["./start.sh"]

