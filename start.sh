#!/bin/bash

set -e

if [ ! -f "/srv/webvirtcloud/webvirtcloud/settings.py" ]; then
    echo "init WebVirtCloud..."
    sudo -u www-data ../startinit.sh # init
fi

# generate ssh keys if necessary
if [ ! -f ~www-data/.ssh/id_rsa ]; then
    echo "create WebVirtCloud ssh key:"
    mkdir -p ~www-data/.ssh/
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
echo "******************************************************************"
echo "echo \"`cat ~www-data/.ssh/id_rsa.pub`\" >> ~/.ssh/authorized_keys"
echo "******************************************************************"


echo "Running supervisor ..."
## /etc/supervisor/supervisord.conf
supervisord -c /etc/supervisor/supervisord.conf

echo "Running nginx ..."
## /etc/nginx/nginx.conf
nginx -g "daemon off;"