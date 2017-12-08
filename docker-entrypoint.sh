#!/bin/bash
set -eo pipefail
shopt -s nullglob

setup() {
        if [ ! -z "$SELFUPDATE" ]; then
		sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
                systemctl enable yum-cron
		yum update -y
        fi

        if [ ! -z "$HTTPD_SERVERADMIN" ]; then    
                sed -i "s/ServerAdmin root@localhost//g" /etc/httpd/conf/httpd.conf
                echo "ServerAdmin $HTTPD_SERVERADMIN" >>/etc/httpd/conf/httpd.conf
        fi

        if [ ! -z "$HTTPD_HARDENING" ]; then    
                sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
                echo "ServerTokens Prod" >>/etc/httpd/conf/httpd.conf
                echo "ServerSignature Off" >>/etc/httpd/conf/httpd.conf
                echo "TraceEnable Off" >>/etc/httpd/conf/httpd.conf
        fi

        if [ ! -z "$TIMEZONE" ]; then
                echo "date.timezone = $TIMEZONE" >>/etc/php.ini
                ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        fi

        if [ ! -z "$LANGUAGE" ]; then
                localedef -i $LANGUAGE -f UTF-8 ${LANGUAGE}.UTF-8
        fi
}

if [ -e /firstrun ] && [ -z "$HTTPD_OMIT_FIRSTRUN" ]; then
        setup
        rm -f /firstrun
fi

exec "$@"
