#! /bin/bash

cp ./config.ini /opt/cm-5.0.1/etc/cloudera-scm-agent/config.ini
cp ./db.properties /opt/cm-5.0.1/etc/cloudera-scm-server/db.properties
cp ./mysql-connector-java-5.1.34.jar /opt/cm-5.0.1/share/cmf/lib/mysql-connector-java-5.1.34.jar
cp ./cmf.principal /opt/cm-5.0.1/etc/cloudera-scm-server/cmf.principal
cp ./cmf.keytab /opt/cm-5.0.1/etc/cloudera-scm-server/cmf.keytab

#
cp ./cloudera-scm-agent /opt/cm-5.0.1/etc/init.d/cloudera-scm-agent
cp ./cloudera-scm-server /opt/cm-5.0.1/etc/init.d/cloudera-scm-server

# chown of cm-5.0.1
chown -R root:root /opt/cm-5.0.1/
# chown of cmf kerberos{principal,keytab}
chown cloudera-scm:cloudera-scm /opt/cm-5.0.1/etc/cloudera-scm-server/cmf.*
chmod 600 /opt/cm-5.0.1/etc/cloudera-scm-server/cmf.*

# service
ln -s /opt/cm-5.0.1/etc/init.d/cloudera-scm-agent /etc/init.d/cloudera-scm-agent
ln -s /opt/cm-5.0.1/etc/init.d/cloudera-scm-agent /etc/init.d/cloudera-scm-server

