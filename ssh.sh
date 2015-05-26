#!/bin/bash

if [ ! -d ~git/.ssh ]; then
  mkdir -p ~git/.ssh
  chmod 700 ~git/.ssh
fi

if [ ! -f ~git/.ssh/environment ]; then
  echo "GOGS_CUSTOM=/data/gogs" > ~git/.ssh/environment
  chown git:git ~git/.ssh/environment
  chown 600 ~git/.ssh/environment
fi

# Non daemon mode.
/usr/sbin/sshd -D
