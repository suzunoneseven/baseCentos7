#!/bin/bash

htpidlist=$(ps -ef | grep httpd | grep -v grep | awk '{print $2}')
for htpid in $htpidlist; do
    kill -9 $htpid
done
if [[ -f "/var/run/httpd/httpd.pid" ]]; then
    rm -f /var/run/httpd/httpd.pid
fi
rm -f /run/httpd/auth*

nohup /usr/sbin/sendmail -L sm-msp-queue -Ac -q1h &
nohup /usr/sbin/sendmail -bd -q1h &
nohup /usr/sbin/apachectl -DFOREGROUND -DSSL &
nohup /usr/bin/mysqld_safe &
sleep 10

echo
echo
echo
echo "# -------------------#"
date
echo "# -------------------#"
echo
tail -Fn0 /var/log/httpd/access_log /var/log/httpd/error_log /var/log/php_errors.log
