#!/bin/bash
#

if [ ! -d /data/gogs ]; then
	mkdir -p /data/gogs/data /data/gogs/conf /data/gogs/log /data/git
fi

test -d /data/gogs/templates || cp -ar ./templates /data/gogs/

ln -sf /data/gogs/log /app/gogs/log
ln -sf /data/gogs/data /app/gogs/data
# ln -sf /data/git /home/git

rsync -rtv /data/gogs/templates/ /app/gogs/templates/

chown -R git:git /data .
exec su git -c "/app/gogs/gogs web"
