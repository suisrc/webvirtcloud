#!/bin/bash

echo "Running migrate and collectstatic"

## 生产密钥
SECRET_KEY=`python3 /srv/webvirtcloud/conf/runit/secret_generator.py`

## 处理配置
cd /srv/webvirtcloud
cp webvirtcloud/settings.py.template webvirtcloud/settings.py
sed -e "s/SECRET_KEY = \"\"/SECRET_KEY = \"${SECRET_KEY}\"/" \
    -e "s/\"db.sqlite3\"/\"data\/db.sqlite3\"/" \
    -i webvirtcloud/settings.py
sed -e "s/workers = get_workers()/workers = 3/" -i gunicorn.conf.py

# fix v0.0.2, 忽略配置
# -e "s/WS_PUBLIC_PORT = 6080/WS_PUBLIC_PORT = ''/" \
# -e "s/WS_PUBLIC_PATH = \"\/novncd\/\"/WS_PUBLIC_PATH = \"novncd\/\"/" \

# 持久化数据目录不存在
if [ ! -d "/srv/webvirtcloud/data" ]; then
    mkdir -p /srv/webvirtcloud/data
fi

## 应用配置
. venv/bin/activate && \
python3 manage.py migrate && \
python3 manage.py collectstatic --noinput