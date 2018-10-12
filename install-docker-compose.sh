#!/bin/bash
#2018年9月26日
#by author caomuzhong
#Blog:www.logmm.com
echo
echo -e "\033[34m======================安装docker compose======================\033[0m"
[ ! -f /usr/local/bin/docker-compose ] && curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
echo -e "\033[34m====================创建部署lnmp的yaml文件====================\033[0m"
cat>docker-compose.yml<<EOF
version: "2"
services:
    mariadb-master: 
       image: centos_mariadb
       container_name: mariadb-5.5.60-master
       ports:
         - "3306:3306"
       environment:
         - MYSQL_ROOT_PASSWORD=123456
       volumes:
         - /testdb/3306/data/:/testdb/3306/data/:rw
       restart: always
    mariadb-slave: 
       image: centos_mariadb
       container_name: mariadb-5.5.60-slave
       ports:
         - "3307:3306"
       environment:
         - MYSQL_ROOT_PASSWORD=123456
       volumes:
         - /testdb/3307/data/:/testdb/3306/data/:rw
         - /testdb/3307/my.cnf:/etc/my.cnf:ro
       restart: always
    mycat:
       image: centos_mycat
       container_name: mycat
       ports:
         - "8066:8066"
         - "9066:9066"
       links:
         - mariadb-master
         - mariadb-slave
       volumes:
         - /root/mycat/server.xml:/usr/local/mycat/conf/server.xml
         - /root/mycat/schema.xml:/usr/local/mycat/conf/schema.xml
       restart: always
    php:
       image: centos_php
       container_name: php-7.2.10
       ports:
         - "9000:9000"
       links:
         - mycat
       volumes:
         - /testweb/:/usr/local/nginx/html:rw
       restart: always
    nginx:
       image: centos_nginx
       container_name: nginx-1.14.0
       ports:
         - "80:80"
         - "443:443"
       links:
         - php
       volumes:
         - /testweb/:/usr/local/nginx/html:rw
         - /var/log/nginx/:/var/log/nginx/:rw
       restart: always
EOF
echo -e "\033[34m********************************************************************************\033[0m"
echo -e "\033[34m  docker-compose.yml文件创建成功，执行docker-compose  up -d命令即可启动容器     \033[0m"
echo -e "\033[34m********************************************************************************\033[0m"
