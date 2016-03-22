#!/bin/bash

mkdir /logs/repo-scanner
mkdir /logs/nginx
mkdir /logs/supervisord

chown nginx:nginx /logs/nginx
echo "Doing initial scan"
createrepo --update /repo
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
