#! /bin/bash

echo 1. kerberos server install package
#yum install krb5-server -y

echo 2. kerberos client install package
#yum install krb5-devel krb5-workstation -y

echo 3. config /etc/krb5.conf
cat > /etc/krb5.conf<<EOF
##cat > 0.conf<<EOF
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = CDH.COM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 clockskew = 120
 #default_tgs_enctypes = aes256-cts-hmac-sha1-96
 #default_tkt_enctypes = aes256-cts-hmac-sha1-96
 #permitted_enctypes = aes256-cts-hmac-sha1-96
 udp_preference_limit = 1


[realms]
 CDH.COM = {
  kdc = paas.cdh.com
  admin_server = paas.cdh.com
 }

[domain_realm]
 .cdh.com = CDH.COM
 cdh.com = CDH.COM
EOF

echo 4. config /var/kerberos/krb5kdc/kdc.conf
cat > /var/kerberos/krb5kdc/kdc.conf<<EOF
#cat > 1.conf<<EOF
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 CDH.COM = {
  master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
  #max_renewable_life = 7d
  #max_life = 1d
  max_life = 7d 0h 0m 0s
  max_renewable_life = 30d 0h 0m 0s 
  default_principal_flags = +renewable, +forwardable

 }
EOF

echo 5. config /var/kerberos/krb5kdc/kadm5.acl
cat > /var/kerberos/krb5kdc/kadm5.acl<<EOF
*/admin@CDH.COM	*
EOF

echo 6. create kerberos database
## securerandom.source=file:/dev/./urandom
## $JAVA_HOME/jre/lib/security/java.security
## ?, doesn't print (a) terminal
echo speedup open a terminal go, cat /dev/sda > /dev/urandom
## Pseudo-terminal will not be allocated because stdin is not a terminal
## ssh -t root@paas.cdh.com "cat /dev/sda > /dev/urandom" &
echo -e "kadmin\nkadmin" | kdb5_util create -r CDH.COM -s

echo 7. create remote manager
## kadmin.local -q "addprinc root/admin"
echo -e "rootadmin\nrootadmin" | kadmin.local -q "addprinc root/admin"

echo 8. get the krb5.keytab, /etc/krb5.keytab
kadmin.local -q "ktadd kadmin/admin"

echo 9. config kerberos service
service krb5kdc start
service kadmin start
chkconfig --levels 35 krb5kdc on
chkconfig --levels 35 kadmin on

echo 10. example to addprincs and keytab
echo using -randkey with addprinc in kadmin shell, get a princ with random passwd
kadmin.local -q "addprinc -randkey test1@CDH.COM"
kadmin.local -q "xst  -k test1.keytab test1@CDH.COM"

echo addprinc, test2/test, test2.keytab
## passwd does not work, cpw to change it
echo -e "test\ntest" | kadmin.local -q "addprinc test2@CDH.COM"
kadmin.local -q "xst  -k test2.keytab test2@CDH.COM"


