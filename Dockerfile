FROM    centos:7
MAINTAINER joramk@gmail.com
ENV     container docker

LABEL   name="CentOS 7 - Latest Apache / PHP / phpMyAdmin" \
        vendor="https://github.com/joramk/el7-httpd-php" \
        license="none" \
        build-date="20171008" \
        maintainer="joramk@gmail.com"

RUN {   yum update -y; yum install systemd yum-utils yum-cron epel-release -y; \
        curl https://repo.codeit.guru/codeit.el7.repo >/etc/yum.repos.d/codeit.el7.repo; \
        yum install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm -y; \
	yum-config-manager --enable remi-php72 --enable remi; \
        yum install httpd openssl logrotate \
	php php-json php-cli \
        php-mbstring php-mysqlnd php-gd php-xml \
        php-bcmath runtime php-common php-pdo \
        php-process php-tidy phpMyAdmin -y; \
        yum clean all; rm -rf /var/cache/yum; \
}

RUN {   (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
        rm -f /lib/systemd/system/multi-user.target.wants/*; \
        rm -f /etc/systemd/system/*.wants/*; \
        rm -f /lib/systemd/system/local-fs.target.wants/*; \
        rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
        rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
        rm -f /lib/systemd/system/basic.target.wants/*; \
        rm -f /lib/systemd/system/anaconda.target.wants/*; \
	rm -f /etc/fstab; touch /etc/fstab; \
	sed -i 's/#ForwardToConsole=no/ForwardToConsole=yes/g' /etc/systemd/journald.conf; \
}

COPY    ./docker-entrypoint.sh /
RUN {   systemctl enable httpd crond; \
        touch /firstrun; \
        chmod +rx /docker-entrypoint.sh; \
}

HEALTHCHECK CMD systemctl -q is-active httpd || exit 1

VOLUME  [ “/sys/fs/cgroup”, "/var/www", "/etc/httpd/conf.d" ]

EXPOSE  80
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/sbin/init" ]
