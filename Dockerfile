FROM    joramk/el8-base
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="CentOS 8 - Latest base Apache / Remi PHP 7.3" \
        vendor="https://github.com/joramk/el8-httpd-php" \
        license="none" \
        build-date="20200407" \
        maintainer="joramk@gmail.com"

RUN {   dnf install http://rpms.famillecollet.com/enterprise/remi-release-8.rpm -y; \
	dnf repolist --enablerepo=remi; \
	dnf module -y install php:remi-7.3 && \
	dnf module -y reset php && \
	dnf module -y enable php:remi-7.3; \
        dnf install -y cronie httpd openssl logrotate \
	php php-json php-cli \
        php-mbstring php-mysqlnd php-gd php-xml \
        php-bcmath php-common php-pdo \
        php-process php-soap; \
        dnf clean all; rm -rf /var/cache/yum; \
}

COPY    ./docker-entrypoint.sh /
RUN {   systemctl enable httpd crond; \
        touch /firstrun; \
        chmod +rx /docker-entrypoint.sh; \
}

HEALTHCHECK CMD systemctl -q is-active httpd || exit 1

VOLUME  [ "/sys/fs/cgroup" ]

EXPOSE  80
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/sbin/init" ]
