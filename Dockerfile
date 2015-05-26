FROM phusion/baseimage:0.9.16
MAINTAINER christophe.eymard@sales-way.com

RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse" > /etc/apt/sources.list && \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y openssh-server git wget unzip
# SSH keys for the host
RUN ssh-keygen -A

# grab binaries and extract them.
RUN mkdir /app/
WORKDIR /app
RUN wget https://github.com/gogits/gogs/releases/download/v0.6.1/linux_amd64.zip && unzip linux_amd64.zip && rm -f linux-amd64.zip
WORKDIR /app/gogs

RUN mkdir /data
RUN useradd --shell /bin/bash --system --comment gogits --home-dir /data/git git

# Enable SSH in the configuration
# RUN mkdir -p /var/run/sshd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -E 's@#?[ \t]*UsePrivilegeSeparation.*@UsePrivilegeSeparation no@' -i /etc/ssh/sshd_config
RUN sed -E 's@#?[ \t]*RSAAuthentication.*@RSAAuthentication yes@' -i /etc/ssh/sshd_config
RUN sed -E 's@#?[ \t]*PubkeyAuthentication.*@PubkeyAuthentication yes@' -i /etc/ssh/sshd_config
RUN sed -E 's@#?[ \t]*AuthorizedKeysFile.*@AuthorizedKeysFile .ssh/authorized_keys@' -i /etc/ssh/sshd_config
# This is so git doesn't shit on me.
RUN sed 's@!@*@' -i /etc/shadow
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# prepare data and location of custom .ini file.
ENV GOGS_CUSTOM /data/gogs
RUN echo "export GOGS_CUSTOM=/data/gogs" >> /etc/profile

RUN apt-get install -y rsync

# Add service for runit
RUN mkdir /etc/service/gogs
ADD gogs.sh /etc/service/gogs/run
RUN mkdir /etc/service/ssh
ADD ssh.sh /etc/service/ssh/run

EXPOSE 3000 22
VOLUME [ "/data" ]

