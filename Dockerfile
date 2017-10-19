# docker build -t base-centos7:latest baseCentos7

FROM centos:centos7
WORKDIR /root
USER root
ENV DB_PASSWORD "xc6367ufE1404Yw1InNROYMVv9uwfTkS"

RUN yum -y reinstall glibc-common
RUN localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8; echo "";

ENV LANG=ja_JP.UTF-8
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN set -x && \
  yum -y remove mariadb-server httpd && \
  rm -rf /var/lib/mysql

ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN set -x && \
  chmod 644 /etc/yum.repos.d/MariaDB.repo && \
  yum -y install epel-release && \
  yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
  sed -i -e 's%^enabled=1%enabled=0%' /etc/yum.repos.d/epel.repo && \
  sed -i -e 's%^enabled=1%enabled=0%' /etc/yum.repos.d/ius.repo && \
  yum -y update
RUN set -x && \
  yum -y install --enablerepo=epel system-logos nghttp2 openssl mailcap && \
  yum -y install --enablerepo=ius --disablerepo=base,extras,updates httpd mod_ssl && \
  yum -y install --enablerepo=remi,remi-php70 php php-devel php-mbstring php-pdo php-gd php-intl php-mysqlnd php-xml php-zip php-pecl-xdebug && \
  yum -y install MariaDB-server MariaDB-client && \
  yum -y install git gcc unzip wget expect sendmail sendmail-cf tcpdump net-tools && \
  yum update -y

ADD my.cnf.1st /etc/my.cnf
ADD auto_mysql_secure_installation.sh /tmp/

RUN set -x && \
  chmod 644 /etc/my.cnf && \
  mkdir -p /var/log/mariadb/ && \
  mkdir -p /var/run/mariadb/ && \
  touch /var/log/mariadb/mariadb.log && \
  chown -R mysql. /var/log/mariadb/ && \
  chown -R mysql. /var/run/mariadb/ && \
  mysql_install_db --user=mysql --ldata=/var/lib/mysql/ && \
  /usr/bin/mysqld_safe --datadir='/var/lib/mysql/' & \
  sleep 30 && \
  chmod +x /tmp/auto_mysql_secure_installation.sh && \
  /tmp/auto_mysql_secure_installation.sh "${DB_PASSWORD}" && \
  rm -f /tmp/auto_mysql_secure_installation.sh &&\
  ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  /usr/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo > /tmp/timezone.sql && \
  mysql -u root -p${DB_PASSWORD} -Dmysql < /tmp/timezone.sql && \
  mysql -u root -p${DB_PASSWORD} -e "flush privileges;" && \
  mysql -u root -p${DB_PASSWORD} -e "grant all privileges on *.* to 'root'@'%' identified by '${DB_PASSWORD}';"  && \
  mysqladmin    -p${DB_PASSWORD} shutdown && \
  echo ${DB_PASSWORD}

ADD my.cnf.2nd /etc/my.cnf
ADD php.ini /etc/php.ini
ADD entrypoint.sh /root/entrypoint.sh

RUN set -x && \
  sed -i -e 's/LANG.*/LANG=ja_JP.UTF-8/' /etc/sysconfig/httpd && \
  chmod 644 /etc/my.cnf && \
  chmod 644 /etc/php.ini && \
  touch /var/log/php_errors.log && \
  chown apache. /var/log/php_errors.log && \
  chmod +x /root/entrypoint.sh && \
  cd /tmp/ && \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
  php -r "unlink('composer-setup.php');"

ENTRYPOINT /root/entrypoint.sh
