FROM    joramk/el8-base
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="CentOS 8 - Latest base Apache / Remi PHP 8.0" \
        vendor="https://github.com/joramk/el8-httpd-php" \
        license="none" \
        build-date="20200407" \
        maintainer="joramk@gmail.com"

RUN {   dnf install http://rpms.famillecollet.com/enterprise/remi-release-8.rpm -y; \
	dnf repolist --enablerepo=remi; \
	dnf module -y install php:remi-8.0 && \
	dnf module -y reset php && \
	dnf module -y enable php:remi-8.0; \
        dnf install -y cronie httpd openssl logrotate glibc-langpack-en glibc-langpack-de \
	php php-json php-cli \
        php-mbstring php-mysqlnd php-gd php-xml \
        php-bcmath php-common php-pdo \
        php-process php-soap; \
        dnf clean all; rm -rf /var/cache/yum; \
}

RUN     systemctl enable httpd crond dnf-automatic.timer

HEALTHCHECK CMD systemctl -q is-active httpd || exit 1

EXPOSE  80
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
