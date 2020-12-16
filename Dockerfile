FROM nimmis/alpine-micro

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY root/. /

RUN apk update && apk -U upgrade -a && \
    # Make info file about this build
    printf "Build of nimmis/alpine-apache, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` >> /etc/BUILD && \
    apk add apache2 libxml2-dev apache2-utils && \
    mkdir /web/ && chown -R apache.www-data /web && \
    mkdir /web/html/ && chown -R apache.www-data /web/html && \
    sed -i 's#PidFile "/run/.*#Pidfile "/web/run/httpd.pid"#g'  /etc/apache2/conf.d/mpm.conf && \
    sed -i 's#/var/log/apache2/#/web/logs/#g' /etc/logrotate.d/apache2 && \
    rm -rf /var/cache/apk/*

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache bash shadow@community openssh openssh-sftp-server && \
    sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY ./users.conf /etc/sftp/users.conf

VOLUME /web

EXPOSE 80 443 22
