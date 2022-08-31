#!/bin/bash

echo "Running migrate and collectstatic"

## 生产密钥
SECRET_KEY=`python3 /srv/webvirtcloud/conf/runit/secret_generator.py`

## 处理配置
cd /srv/webvirtcloud
cp webvirtcloud/settings.py.template webvirtcloud/settings.py
sed -e "s/SECRET_KEY = \"\"/SECRET_KEY = \"${SECRET_KEY}\"/" -i webvirtcloud/settings.py
sed -e "s/workers = get_workers()/workers = 3/" -i gunicorn.conf.py

## 应用配置
. venv/bin/activate && \
python3 manage.py migrate && \
python3 manage.py collectstatic --noinput