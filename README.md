# docker-for-lnmp
LNMP架构docker化脚本

一、系统环境
在一台机子上跑nginx、mariadb、php共3个容器
软件版本：nginx-1.14.0、mariadb-5.5.60、php-7.2.7
宿主机系统：RHEL 7.5（3.10.0-862.el7.x86_64 #1 SMP Wed Mar 21 18:14:51 EDT 2018 x86_64 x86_64 x86_64 GNU/Linux）

二、文件
目录文件结构：

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
[root@lb02 ~]# tree php7/
php7/
└── Dockerfile

0 directories, 1 file
[root@lb02 ~]# 

三、脚本的执行
1、先执行install_docker.sh脚本，生成nginx、mariadb、php的Dockerfile文件
2、再按照脚本的提示，手动构建镜像
3、最后执行install_docker-compose.sh脚本，生成yaml文件

yml文件创建成功后，执行docker-compose  up -d命令即可启动容器。

说明：网站目录、数据库data目录通过挂载本地目录实现持久化。
其他的，比如，日志文件、配置文件等没有实现持久化，而是整合到镜像之中。
你可以根据实际需要，对某些文件实现持久化。

