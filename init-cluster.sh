#! /bin/bash

CMF_SOFT=/opt/toolbox-cdh5/cdh540
CMF_PARCEL=/opt/cloudera/parcel-repo
CMF_CM=/opt/cm-5.4.0
CMF_MYSQL_HOST=paas.cdh.com

## custom config
server_host=paas.cdh.com


echo 1. config clouder-manager
echo ./cm-5.4.0, ./cloudera,./cloudera/parcel-repo,./cloudera/csd
## tar -zxvf $CMF_SOFT/cloudera-manager-el6-cm5.4.0_x86_64.tar.gz -C /opt

echo 2. local parcels
#mkdir -p $CMF_PARCEL
#cp $CMF_SOFT/CDH-5.4.0-1.cdh5.4.0.p0.27-el5.parcel $CMF_PARCEL
#cp $CMF_SOFT/CDH-5.4.0-1.cdh5.4.0.p0.27-el5.parcel.sha $CMF_PARCEL

echo 3. jdbc
#cp mysql-connector-java-5.1.34.jar $CMF_CM/share/cmf/lib/

echo 4. config server_host, jdbc_driver

#etc/cloudera-scm-agent/config.ini

sed -i "s:server_host=localhost:server_host=$server_host:" $CMF_CM/etc/cloudera-scm-agent/config.ini

sed -i "s:#cloudera_mysql_connector_jar=/usr/share/java/mysql-connector-java.jar:cloudera_mysql_connector_jar=$CMF_CM/share/cmf/lib/mysql-connector-java-5.1.34.jar:" $CMF_CM/etc/cloudera-scm-agent/config.ini

echo 5. create user cloudera-scm

## useradd --system --home=$CMF_CM/run/cloudera-scm-server/ --no-create-home --shell=/bin/false --comment "Cloudera SCM User" cloudera-scm

echo 6. \[CONFIG\] cloudera-scm-server/agent CMF_DEFAULTS
#echo export BASE_SOURCE=$CMF_CM >> /etc/profile
#. /etc/profile

#way#2
sed -i 's:CMF_DEFAULTS=$(readlink -e $(dirname ${BASH_SOURCE-$0})/../default):CMF_DEFAULTS=$(readlink -e $(dirname $(readlink -e $0))/../default):' $CMF_CM/etc/init.d/cloudera-scm-server
sed -i 's:CMF_DEFAULTS=$(readlink -e $(dirname ${BASH_SOURCE-$0})/../default):CMF_DEFAULTS=$(readlink -e $(dirname $(readlink -e $0))/../default):' $CMF_CM/etc/init.d/cloudera-scm-agent

echo 7. init db config
## 1. write to db.properties, 2. create database cmf to mysql
echo 'using -h has privileges q'
mysql -uroot -pmysqladmin -e "grant all on cmf.* to scm@'%' identified by 'scm';"
mysql -uroot -pmysqladmin -e "grant all on cmf.* to scm@'localhost' identified by 'scm';"
/opt/cm-5.4.0/share/cmf/schema/scm_prepare_database.sh mysql cmf -uroot -pmysqladmin --scm-host $CMF_MYSQL_HOST scm scm scm

echo 8. kerberos cmf.principal, cmf.keytab

echo 9. dispatch,rsync
