#!/bin/bash
#2018年9月26日
#by author caomuzhong
#Blog:www.logmm.com
echo
echo -e "\033[34m======================安装docker compose======================\033[0m"
[ ! -f /usr/local/bin/docker-compose ] && curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
echo -e "\033[34m====================创建部署lnmp的yaml文件====================\033[0m"
cat>docker-compose.yml<<EOF
version: "3"
services:
    mariadb: 
       build: mariadb/
       image: centos_mariadb
       container_name: mariadb-5.5.60
       ports:
         - "3306:3306"
       environment:
         - MYSQL_ROOT_PASSWORD=123456
       volumes:
         - /mariadb/3306/data/:/mariadb/3306/data/
       restart: always
    php:
       build: php/
       image: centos_php
       container_name: php-7.2.10
       ports:
         - "9000:9000"
       links:
         - mariadb
       volumes:
         - /wwwroot/:/usr/local/nginx/html
       restart: always
    nginx:
       build: nginx/
       image: centos_nginx
       container_name: nginx-1.14.0
       ports:
         - "80:80"
         - "443:443"
       links:
         - php
       volumes:
         - /wwwroot/:/usr/local/nginx/html
         - /var/log/nginx/:/var/log/nginx/
       restart: always
EOF
echo -e "\033[34m*****yml文件创建成功，执行docker-compose  up -d命令即可启动容器*****\033[0m"
