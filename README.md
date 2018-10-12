
# LNMP架构docker化脚本

==========================

【一、系统环境】

==========================

软件版本：nginx-1.14.0、mariadb-5.5.60、php-7.2.10

宿主机系统：RHEL 7.5

宿主机网站目录：/testweb，数据库data目录：/testdb/3306/data,/testdb/3307/data/

其中，3306目录为主库，3307目录为从库

【为方便测试，数据库root用户，密码：123456，授权host为%。实际中，必须修改。】

宿主机关闭防火墙和selinux

==========================

【二、功能说明】

==========================

总共有3个脚本文件：

install-docker.sh：该脚本主要是创建nginx、mariadb、php的配置文件及其

Dockerfile文件、宿主机网站、数据库data目录以及相关的用户和组。脚本执行

完成后，按照提示去创建镜像。

install-mycat-for-docker.sh：此脚本主要创建mycat的Dockerfile文件。【必须

把jdk1.8的rpm软件包下载放到/root/mycat目录中，并且重命名为jdk1.8.rpm，

才能执行构建命令！】

install-docker-compose.sh：此脚本用户生成容器编排的yaml文件。

==========================

【三、文件目录】

==========================

3个脚本执行完成后，生成的目录文件结构：

[root@lb02 ~]# tree mariadb/

mariadb/

├── Dockerfile

└── start.sh

0 directories, 2 files

[root@lb02 ~]# tree nginx

nginx

├── Dockerfile

├── nginx.conf

└── server.conf

0 directories, 3 files

[root@lb02 ~]# tree php/

php/

└── Dockerfile

0 directories, 1 file


[root@lb02 ~]# tree mycat/

mycat/

├── Dockerfile

├── jdk1.8.rpm ---此软件包并非脚本生成，得自己下载放到此目录中。

├── schema.xml

└── server.xml

0 directories, 4 files

[root@lb02 ~]# 

==========================

【四、mariadb主从】

==========================

容器启动后，需要手动配置mariadb数据库主从

3306端口为主库端口，3307端口为从库端口,均映射到容器中的3306端口。

主库：/testdb/3306/data/

从库：/testdb/3307/data/

==========================

【五、读写分离】

==========================

全部容器启动成功后，mycat读写分离已经配置好了。自定义的配置文件为：

/root/mycat目录中的schema.xml、server.xml，可根据实际修改。

==========================

我的博客：www.logmm.com  2018-10-12修改

==========================
