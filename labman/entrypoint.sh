#!/bin/sh

cd labman_ud

export DJANGO_SETTINGS_MODULE=labman_ud.settings.prod

./manage.py migrate ;
./manage.py collectstatic --noinput;
./manage.py runserver 0.0.0.0:8000 ;