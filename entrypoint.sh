#!/bin/bash

mkdir /logs/repo-scanner
mkdir /logs/nginx
mkdir /logs/supervisord

chown nginx:nginx /logs/nginx

chmod -R 0777 /repo

if [[ "${SERVE_FILES}" == "true" ]]; then
    echo "Serving Files is on"
cat << EOF >> /etc/supervisord.conf
[program:nginx]
priority=10
directory=/
command=/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
user=root
autostart=true
autorestart=true
stopsignal=QUIT
redirect_stderr=true
EOF
else 
    echo "Serving Files is off"
fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
