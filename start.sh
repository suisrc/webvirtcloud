#!/bin/bash

set -e

if [ ! -f "/srv/webvirtcloud/webvirtcloud/settings.py" ]; then
    echo "init WebVirtCloud..."
    ./startinit.sh # init
fi

# generate ssh keys if necessary
if [ ! -f ~www-data/.ssh/id_rsa ]; then
    echo "create WebVirtCloud ssh key:"
    ssh-keygen -b 4096 -t rsa -C webvirtcloud -N '' -f ~www-data/.ssh/id_rsa
    cat > ~www-data/.ssh/config << EOF
Host *
StrictHostKeyChecking no
EOF
    chown -R www-data:www-data /var/www/.ssh/
    chmod 0700 /var/www/.ssh
    chmod 0600 /var/www/.ssh/*
fi
echo ""
echo "Your WebVirtCloud public key:"
cat ~www-data/.ssh/id_rsa.pub
echo ""

## /etc/supervisor/supervisord.conf
supervisord -c /etc/supervisor/supervisord.conf

## /etc/nginx/nginx.conf
nginx -g "daemon off;"