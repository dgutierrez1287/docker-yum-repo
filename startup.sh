#!/bin/bash

mkdir /logs/repo-scanner
mkdir /logs/nginx
mkdir /logs/supervisord

chown nginx:nginx /logs/nginx

exec /usr/bin/supervisord -n -c /etc/supervisord.conf