
# LNMP架构docker化脚本

【一、系统环境】

=========================================================================

在一台机子上跑nginx、mariadb、php共3个容器

软件版本：nginx-1.14.0、mariadb-5.5.60、php-7.2.10

宿主机系统：RHEL 7.5

宿主机网站目录：/wwwroot，数据库data目录：/mariadb/3306/data。

宿主机关闭防火墙和selinux

【二、文件目录】

===========================================================================

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

[root@lb02 ~]# tree php/

php/

└── Dockerfile

0 directories, 1 file

[root@lb02 ~]# 


【三、脚本的执行】

============================================================================

1、先执行install_docker.sh脚本，生成nginx、mariadb、php的Dockerfile文件

2、然后按照脚本的提示，手动构建镜像

3、再执行install_docker-compose.sh脚本，生成yaml文件

4、yml文件创建成功后，执行docker-compose  up -d命令即可启动容器。

说明：网站目录、数据库data目录通过挂载本地目录实现持久化。

其他的，比如，日志文件、配置文件等没有实现持久化，而是整合到镜像之中。

你可以根据实际需要，对某些文件实现持久化。

=============================================================================

我的博客：www.logmm.com

