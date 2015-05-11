Centos6.5 x64 cdh5.0.1 kerberos 配置记录整理 20150509
===========
基于centos6.5 安装cdh5.0.1, 配置kerberos环境手册.

<h3> 目录:</h3>
	
	*  0. virtual box 安装配置
	*  1. mini 安装 centos6.5
	*  2. 添加第三方源 epel
	*  3. 安装额外的软件包
	*  4. yum update 更新系统
	*  6. 配置jdk1.7.0_65
	*  7. 安装 JCE, 扩展加密, aes 256
	*  8. 配置cdh本地parcels源
	*  9. 克隆, 共得到3台环境
	* 10. 集群环境网络、主机规划配置
	* 11. 集群免密码登录
	* 12. cloudera manager(cm) 元数据库 mysql安装
	* 13. cm 本地环境配置server,agent
	* 14. 分发同步 cm
	* 14. cdh 集群安装
	* 15. kdc 安装配置
	* 16. 额外的sasl包配置
	* 17. cdh配置 kerberos
	* 18. hue 配置 kerberos 认证, 配置检查beeswax块(hive server2)
	* 19. 集群环境基准测试用户super 配置, 使用hadoop-example的pi验证配置
	* 20. 系统超级管理员初始化
	* 21. 参考

<h4>一、virtual box, centos 安装配置</h4>

1. thinkpad 开启硬件虚级化

		1. 同时按住 fn,esc 常启fn功能键, 使f1,f2,...,f12键做为f1,f2,...f12使用
		2. 开机按住f8, 进入bios,  enabled virtualization配置
2. virtualbox 安装 centos6.5 x64版, 最小化安装, 也可以选择桌面版, 网络连接方式, 使用桥接方式

<h4>二、安装yum源, 系统更新</h4>

1. yum search epel, 搜索epel源, 有更多的软件包可用
2. yum instal epel-release安装
3. 安装必要的开发软件包
	
		* yum install which rpcbind gcc gcc-c++ cmake tar libtar bzip2 lizip libzip-devel bzip2-devel bzip2-libs
		* yum install rsync 
		
4. 安装SASL相关包(hue整合hive时需要)

		* yum install cyrus-sasl-plain cyrus-sasl-gssapi cyrus-sasl-devel

5. yum update 更新系统

6. 配置 默认启动方式为命令行/etc/inittab 

		id:3:initdefault:
		
<h4>二、jdk1.7.0_65, jce</h4>

1. 软件包 jdk1.7.0_65.tar.gz
2. 解压到 /usr/java
3. 做软链接, ln -s /usr/java/jdk1.7.0_65 /usr/java/latest
4. 使用alternatives 安装 javac,java,jws等
	
		alternatives --install /usr/bin/java java /usr/java/latest/bin/java 20
   		alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 20
   		alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 20
   		alternatives --install /usr/bin/jar jar /usr/latest/bin/jar 20
   		alternatives --install /usr/bin/jps jps /usr/java/latest/bin/jps 20
 
   		
5. 配置JAVA_HOME, 在/etc/profile追加以下内容

 		JAVA_HOME=/usr/local/java/latest
		CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
		export JAVA_HOME CLASSPATH

6. 下载jdk7版jce, 并覆盖到$JAVA_HOME/jre/lib/security/, 替换以下内容

		 local_policy.jar
		 US_export_policy.jar
		 
<h4>三、cdh 离线parcel源配置</h4>
		 
1. cdh 默认的parcels源路径为 /opt/cloudera/parcel-repo, 配置好后, 内容如下

		/opt/cloudera/parcel-repo/
		├── CDH-5.0.1-1.cdh5.0.1.p0.47-el6.parcel
		└── CDH-5.0.1-1.cdh5.0.1.p0.47-el6.parcel.sha
		
		特别注意:
			* CDH-5.0.1-1.cdh5.0.1.p0.47-el6.parcel.sha 文件名
			* CDH-5.0.1-1.cdh5.0.1.p0.47-el6.parcel.sha 内容为 CDH-5.0.1-1.cdh5.0.1.p0.47-el6.parcel文件的sha1sum值: ec68971d2969a5a31e720a2a79ce7a7c1d38e397
			* 文件名错误将导致改版本不可用, cm 默认安装大版本的最新版
			* 文件内容错误将导致本地换成parcel无效, 安装时需要在线联网去下载

<h4>四、通过以上步骤, 得到母机.</h4>
<h4>五、母机网络配置</h4>
	
1. 本地网络环境, 网关 192.168.0.1
2. 规划集群环境三台, 网络、主机名配置如下

		ip             hostname				role
		192.168.0.151  cdh50101.cdh.com	cm{server,agent}, mysql server, kdc
		192.168.0.152  cdh50102.cdh.com	cm{agent}
		192.168.0.153  cdh50103.cdh.com	cm{agent}
3. 网络配置

	3.1 /etc/hosts
	
		127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
		::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
		#kvm.com
		192.168.0.151  cdh50101.cdh.com
		192.168.0.152  cdh50102.cdh.com
		192.168.0.153  cdh50103.cdh.com

	3.2 /etc/sysconfig/network
	
		NETWORKING=yes
		HOSTNAME=cdh50101.cdh.com
		NETWORKING_IPV6=no
		GATEWAY=192.168.0.1
		
	3.3 网络ip
	
		DEVICE=eth0
		HWADDR=08:00:27:D3:76:B7
		TYPE=Ethernet
		UUID=4e11ebcb-e80f-49a2-9663-a8b65d0a9226
		ONBOOT=yes
		NM_CONTROLLED=yes
		BOOTPROTO=static
		IPADDR=192.168.0.151
		GATEWAY=192.168.0.1
		PREFIX=24
		DEFROUTE=yes
		IPV4_FAILURE_FATAL=yes
		IPV6INIT=no
		DNS1=192.168.0.1
		
	3.4 关闭防火墙
	
		service iptables stop
		service ip6tables stop
		setenforce 0
		
		
<h4>六、virtual box 克隆虚拟机、网络更新</h4>

1. 再virtualbox对母机克隆, 注意勾选重置mac地址选项, 对到cdh50102,cdh50103
2. 分别进入cdh50102,cdh50103网络修正:

		* 通过 ifconfig eth1|grep HWaddr|awk '{print $5}'得到新的mac地址
		* nmcli con|grep eth1|awk '{print $3}', 得到新的uuid
		* 使用以上2步得到的mac,uuid更新ifconfig-eth0
		* 修正 /etc/udev/rules.d/70-persistent-net.rules, 注释掉老eth0网卡, 将新网卡eth1标识改为eth0
3. 由上得到3台虚拟机cdh50101.cdh.com,cdh50102.cdh.com,cdh50103.cdh.com

<h4>七、配置元数据库mysql</h4>

1.安装mysql

	yum install mysql mysql-server mysql-libs
	

2.service mysqld start 启动数据库, 按提示配置root密码mysqladmin

3.配置编码以及忽略大小写, 编辑文件/etc/my.cnf, 再[mysqld]段添加

	# no difference betwen up,lower case, table name
	lower_case_table_names=1
	# charset
	character_set_server = utf8
	collation-server = utf8_general_ci
	character_set_client = utf8
	
	
<h4>八、免密码输入登陆集群</h4>

1. 在3台主机分别执行使用rsa加密算法生成

		ssh-keygen -t rsa -P ""
		ssh-copy-id -i root@cdh50101.cdh.com

3. 再cdh50101.cdh.com 执行同步 /root/.ssh/authorized_keys操作

		scp /root/.ssh/authorized_keys root@cdh50102.cdh.com:/root/.ssh/authorized_keys
		scp /root/.ssh/authorized_keys root@cdh50103.cdh.com:/root/.ssh/authorized_keys

<h4>九、KDC以及客户端配置</h4>

1. 服务端安装
	
		yum install krb5-server

2. 客户端安装

		yum install krb5-devel krb5-workstation

3. 配置kdc配置文件/etc/krb5.conf

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
		  kdc = cdh50101.cdh.com
		  admin_server = cdh50101.cdh.com
		 }

		[domain_realm]
		 .cdh.com = CDH.COM
		 cdh.com = CDH.COM
4. 配置 /var/kerberos/krb5kdc/kdc.conf
		
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
5. 配置 /var/kerberos/kadmin5.conf

		*/admin@CDH.COM	*
		
6. 配置启动kdc服务

		chkconfig --levels 35 kadmin on
		chkconfig --levels 35 krb5kdc on
		
		service kadmin start
		service krb5kdcon start

7. 生成kdc数据库
		
		kdb5_util create -r CDH.COM -s
		密码: kdcadmin/kdcadmin
8. 登陆kdc

		有 kdc 服务器 root 权限账号(系统账号), 无 kdc admin 账号(kdc 数据库账号), 使用 kadmin.local
		无 kdc 服务器 root 权限账号, 有 kdc admin 账号, 使用 kadmin
9. 配置远程管理员密码

		添加principal
			kadmin.local -q "addprinc root/admin"
		配置有密码交互principal
			echo -e "rootadmin\nrootadmin" | kadmin.local -q "addprinc root/admin"
			
10. 抽取管理keytab到/etc/krb5.keytab

		kadmin.local -q "ktadd kadmin/admin"
		
11.

	创建 principal
           ☐ -randkey 标志没有为新 principal 设置密码，而是指示 kadmin 生成一个随机密钥。之所以在这里使用这个标志，是因为此 principal 不需要用户交互。它是计算机的一个服务器帐户。
           kadmin.local -q "addprinc -randkey hdfs/hostname@DOMAIN"
           kadmin.local -q "addprinc -randkey hdfs@DOMAIN"
    ☐ 创建keytab文件
             ☐ xst -norandkey -k hdfs.keytab hdfs/fully.qualified.domain.name host/fully.qualified.domain.name
             语法不支持:
               ☐ Principal -norandkey does not exist
               ☐ kadmin.local -q "xst  -k hdfs-unmerged.keytab  host/fully.qualified.domain.name"
             ☐ keytab 合并:
               ☐ ktutil
                 ☐ rkt
                 ☐ wkt
         ☐ [#](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_sg_users_groups_verify.html)
         
12.

	创建用户:
           1. 集群系统用户(无主目录、无shell、userid > 1000)
             useradd $1  -M -s /sbin/nologin -u $100010?
             ? /sbin/false?
           2. kerberos principal
             echo -e "$1\n$1" | kadmin.local -q "addprinc $1@CDH.COM"
           3. 抽取keytab
             kadmin.local -q "xst  -k /opt/$1.keytab $1@CDH.COM"
           实例:
             ssh -t root@cdh50101.cdh.com "useradd super  -M -s /sbin/nologin -u 100011"
             ssh -t root@cdh50102.cdh.com "useradd super  -M -s /sbin/nologin -u 100011"
             ssh -t root@cdh50103.cdh.com "useradd super  -M -s /sbin/nologin -u 100011"

             echo -e "super\nsuper" | kadmin.local -q "addprinc super@CDH.COM"

             kadmin.local -q "xst  -k /opt/super.keytab super@CDH.COM"

             kadmin.local -q "xst -k /opt/pass-conf/hue1.keytab hue/cdh50101.cdh.com@CDH.COM"

<h4>十、配置cloudera manager</h4>

1. 执行 cm501-init-patch/config.sh

		配置 cm server
		配置 mysql驱动
		初始化脚本
		配置cmf kerberos账户: cmf.principal, cmf.keytab
		配置初始化脚本,修改CMF_DEFAULTS
	
2. 同步分发cm-5.0.1

		rsync -av cm-5.0.1 root@cdh50102.cdh.com:/opt
		rsync -av cm-5.0.1 root@cdh50102.cdh.com:/opt
		
3. 按角色启动cm, 并按导航安装cm 免费版, cdh501, 安装服务组件

		zk,3台
		hdfs,dn 3台
		hbase
		hive
		sqoop2
		oozie
		hue
		
<h4>十一、配置 cm开启kerberos</h4>

		CM ENABLE KERBEROS:
      ☐ 1. Administrator>Settings,Kerberos Security Realm 
      ☐ 2. ZK,Enable Kerberos Authentication
      3. hdfs:
        ☐ 3.1, hdfs.user.to.impersonate: hdfs
        ☐ 3.2, Hadoop Secure Authentication
        ☐ 3.3, Trusted Kerberos Realms
        ☐ 3.4, Hadoop Secure Authorization
        ☐ 3.5, DataNode Transceiver Port, 1004 <1024
        ☐ 3.6, DataNode HTTP Web UI Port/dfs.datanode.http.address, 1006
        额外:
        ☐ NameNode and SecondaryNameNode have same heapsizes, 256
      4. hbase:
        ☐ 4.1, hbase.superuser, hbase, @非常重要, 否者acl中内容为空, 无法操作
        ☐ 4.2, hbase.security.authentication, kerberos
        ☐ 4.3, hbase.security.authorization
      5. hue:
        ☐ ktr, Kerberos Ticket Renewer, 添加服务, All Hue roles must be on the same host
      6. Administrator, kerberos:
        ☐ generate credentials
      7. Deploy Client Configuration
      
<h4>十二、配置hue kerberos认证</h4>

1. 修改 /etc/hue/conf/hue.ini 修改 [[kerberos]]端
	
		hue_keytab=./hue.keytab
		hue_principal=hue/cdh50103.cdh.com
	   注意:
	   		keytab 使用相对路径，cm启动hue时, 会自动转到到ticker_renewer服务下的绝对路径keytab路径
			其中cdh50103.cdh.com是实例环境下hue的安装主机
			
2. 配置hive, 修改[[beeswax]]段, 配置hive_server_host值为hive server2实例启动主机

		hive_server_host=cdh50101.cdh.com
		
<h4>十三、集群超级管理员配置</h4>
		
3. benchmark 基准测试
	
		kdestroy #销毁缓存
		kinit super #登陆登陆
		klist # 查看当前kerberos认证principal
		hadoop 基准测试:
			hadoop jar hadoop-mapreduce-examples-2.3.0-cdh5.0.1.jar pi 3 10
	
<h4>十四、集群超级管理员配置</h4>

	hdfs, 超级管理员 hdfs
	hive cli, 超级管理员: grant all to user super
	hbase, 超级管理员 hbase, grant 'super', 'RWCXA'
	
<h4>十五、参考</h4>

[Configuring-Hadoop-Security-with-Cloudera-Manager](http://www.cloudera.com/content/cloudera/en/documentation/archives/cloudera-manager-4/v4-5-2/Configuring-Hadoop-Security-with-Cloudera-Manager/cmeechs_topic_4_14.html)

[cdh5sg_hue_kerberos_config](http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Security-Guide/cdh5sg_hue_kerberos_config.html)

[JavaChen Blog](http://blog.javachen.com)

[hue-hive-sasl](http://blog.sina.com.cn/s/blog_40d46ec20101fd4s.html)
		
	
		
	
		

	
		

		



