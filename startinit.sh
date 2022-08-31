#!/bin/bash

echo "Running migrate and collectstatic"
SECRET_KEY=`python3 /srv/webvirtcloud/conf/runit/secret_generator.py` &&\
cd /srv/webvirtcloud &&\
cp webvirtcloud/settings.py.template webvirtcloud/settings.py &&\
sed -r "s/SECRET_KEY = \"\"/SECRET_KEY = \"${SECRET_KEY}\"/" -i webvirtcloud/settings.py &&\
. venv/bin/activate && \
python3 manage.py migrate && \
python3 manage.py collectstatic --noinput
echo "Applying permission for www-data"
chown -R www-data:www-data /srv/webvirtcloud/