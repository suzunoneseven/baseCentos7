# baseCentos7
centos7 base

## Auto Run Application(entrypoint)
1. httpd
1. sendmail
1. mysqld_safe(MariaDB)

## Display Log
* /var/log/httpd/access_log (httpd access log)
* /var/log/httpd/error_log (httpd error log)
* /var/log/php_errors.log (php error log)

## Install Application
* yum repository
    * epel
    * remi
    * ius
    * MariaDB
* web
    * apache httpd 2.4
* PHP
    * (composer)
    * php 7.0
        * gd
        * intl
        * mbstring
        * mysqlnd
        * pdo
        * xdebug
        * xml
        * zip
* DB
    * MariaDB-server 10.2
    * MariaDB-client 10.2
* Mail
    * sendmail
* etc
    * expect
    * git
    * net-tools
    * tcpdump
    * unzip
    * wget

## ENV
* DB_PASSWORD
    * MariaDB root user password
    * default`xc6367ufE1404Yw1InNROYMVv9uwfTkS`
