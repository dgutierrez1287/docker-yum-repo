#!/bin/bash

mkdir /logs/repo-scanner
mkdir /logs/nginx
mkdir /logs/supervisord

chown nginx:nginx /logs/nginx

echo "Doing initial scan"
paths=$(find /repo -type f -name "*.rpm" -exec dirname {} \; | sort | uniq)
for path in $paths ; do
    echo -n "Scanning ${path}..."
    createrepo --update $path
    echo "  done!"
done

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
