#!/bin/bash

mkdir /root/logs/repo-scanner
mkdir /root/logs/nginx
mkdir /root/logs/supervisord

chown nginx:nginx /root/logs/nginx

exec /usr/bin/supervisord -n -c /etc/supervisord.conf