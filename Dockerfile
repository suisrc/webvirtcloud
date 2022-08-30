FROM debian:bullseye-slim

LABEL maintainer="suisrc@outlook.com"

ARG SRV_HOME=/srv
ARG S6_RELEASE=v3.1.2.0

# linux and softs
RUN apt update && apt install --no-install-recommends -y \
    sudo ca-certificates curl git procps jq bash net-tools iputils-ping zsh vim nano ntpdate locales openssh-server xz-utils libatomic1 \
    p7zip fontconfig gcc dpkg build-essential libz-dev zlib1g-dev &&\
    sed -i "s/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen && locale-gen &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

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



