#!/bin/bash
#author:caomuzhong
#date:2018-9-26
#一键部署lnmp架构容器化

echo -e "\033[31;32m*****************************************************\033[0m"
echo -e "\033[31;32m================一键部署lnmp容器化===================\033[0m"
echo -e "\033[31;32m*****************************************************\033[0m"
echo
echo "版本：nginx：1.14.0  mariadb：5.5.60  php：7.2.7"
echo
echo -e "\033[31;32m===========部署前的准备=========\033[0m"
echo -e "\033[31;32m-----------创建www用户和组---------\033[0m"
id www &> /dev/null
[ $? -ne 0 ] && groupadd -g 1080 www && useradd -g 1080 -u 1080 -M -s /sbin/nologin www
echo -e "\033[31;32m-----------创建mysql用户和组---------\033[0m"
id mysql &> /dev/null
[ $? -ne 0 ] && groupadd -g 3306 mysql  && useradd -g 3306 -u 3306 -M -s /sbin/nologin mysql
echo -e "\033[31;32m-----------创建网站目录和数据库data目录---------\033[0m"
[ ! -d /wwwroot ] && mkdir /wwwroot && chown -R www.www /wwwroot && chmod -R 777 /wwwroot
[ ! -d /mariadb/3306/data ] && mkdir /mariadb/3306/data -p && chown -R mysql.mysql /mariadb/3306/data && chmod -R 777 /mariadb/3306/data
echo
echo -e "\033[31;32m===========安装docker=========\033[0m"
echo -e "\033[31;32m-----------下载repo文件---------\033[0m"
[ ! -f /etc/yum.repos.d/docker-ce.repo ] && curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum clean all &> /dev/null && yum makecache &> /dev/null
yum install docker-ce -y
echo -e "\033[31;32m-----------设置加速器---------\033[0m"
[ ! -d /etc/docker ] && mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
 "registry-mirrors": ["http://hub-mirror.c.163.com","https://registry.docker-cn.com","https://dhq9bx4f.mirror.aliyuncs.com"]
}
EOF
systemctl start docker && echo -e "\033[31;32m-----------docker启动成功---------\033[0m"
echo -e "\033[31;32m===================================\033[0m"
echo -e "\033[31;32m    创建nginx、mariadb、php镜像    \033[0m"
echo -e "\033[31;32m===================================\033[0m"
[ ! -d nginx ] && mkdir nginx 
[ ! -d mariadb ] && mkdir mariadb
[ ! -d php ] && mkdir  php
cat>nginx/nginx.conf<<EOF
user  www www;
worker_processes  1;
worker_rlimit_nofile 65535;
error_log  /var/log/nginx/error.log notice;
events {
    use epoll;
    worker_connections  65535;
}
http {
    include mime.types;
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    log_format combined_realip '\$remote_addr \$http_x_forwarded_for [\$time_local]'
    ' \$host "\$request_uri" \$status'
    ' "\$http_referer" "\$http_user_agent"';
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    connection_pool_size 256;
    client_header_buffer_size 1k;
    large_client_header_buffers 8 4k;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    client_max_body_size 10m;
    client_body_buffer_size 256k;
    client_body_temp_path /usr/local/nginx/client_body_temp;
    proxy_temp_path /usr/local/nginx/proxy_temp;
    fastcgi_temp_path /usr/local/nginx/fastcgi_temp;
    fastcgi_intercept_errors on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_types text/plain application/x-javascript text/css text/htm 
    application/xml;
    
    include /usr/local/nginx/conf.d/*.conf;
}
EOF
cat>nginx/server.conf<<EOF
server {
listen       80;
server_name  localhost;
location / {
    root   /usr/local/nginx/html;
    index  index.php index.html index.htm;
}
location ~ \.php\$ {
    root           /usr/local/nginx/html;
    fastcgi_pass   php:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME   /usr/local/nginx/html\$fastcgi_script_name;
    include        fastcgi_params;
}
}
EOF
echo -e "\033[31;32m================创建nginx Dockerfile===========\033[0m"
cat>nginx/Dockerfile<<EOF
FROM centos

#File Author / Maintainer
MAINTAINER caomuzhong www.logmm.com

#Install necessary tools
RUN yum install -y gcc gcc-c++ pcre-devel openssl-devel libxml2-devel openssl libcurl-devel make zlib zlib-devel gd-devel

#Install Nginx
RUN groupadd -g 1080 www && useradd  -g 1080 -u 1080 -s /sbin/nologin www \
   &&  mkdir -p /usr/local/nginx/ \
   &&  mkdir -p /var/log/nginx  \
   &&  chown www.www /var/log/nginx \
   &&  touch /var/log/nginx/error.log \
   &&  chown www.www /var/log/nginx/error.log
ADD http://nginx.org/download/nginx-1.14.0.tar.gz .
RUN tar xf nginx-1.14.0.tar.gz && rm -f nginx-1.14.0.tar.gz \
   &&  cd nginx-1.14.0 && ./configure --prefix=/usr/local/nginx \
       --user=www \
       --group=www \
       --http-log-path=/var/log/nginx/access.log \
       --error-log-path=/var/log/nginx/error.log \
       --with-http_ssl_module \
       --with-http_realip_module \
       --with-http_flv_module \
       --with-http_mp4_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_image_filter_module \
       --with-http_stub_status_module &&  make && make install && yum clean all

RUN rm -f /usr/local/nginx/conf/nginx.conf && mkdir /usr/local/nginx/conf.d/
COPY nginx/nginx.conf  /usr/local/nginx/conf/nginx.conf
COPY nginx/server.conf /usr/local/nginx/conf.d/

#Expose ports
EXPOSE 80 443

#Front desk start nginx
ENTRYPOINT ["/usr/local/nginx/sbin/nginx","-g","daemon off;"] 
EOF
echo -e "\033[31;32m================创建mariadb Dockerfile===========\033[0m"
cat>mariadb/start.sh<<EOF
#!/bin/bash
if [ ! -f mariadb/3306/data/ibdata1 ]; then
       chown -R mysql.mysql /mariadb/3306/data/
       /usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/mariadb/3306/data/
        /etc/rc.d/init.d/mariadb start
        /usr/local/mysql/bin/mysql -e "grant all on *.* to 'root'@'%' identified by '123456' with grant option;"
        /usr/local/mysql/bin/mysql -e "flush privileges;"     
fi
/etc/rc.d/init.d/mariadb restart
tail -f /etc/passwd
EOF
cat>mariadb/Dockerfile<<EOF
###  Set the base image to CentOS
FROM centos

#File Author / Maintainer
MAINTAINER caomuzhong www.logmm.com

#Create mysql user and Data dir
RUN groupadd -g 3306 mysql && useradd -g 3306 -u 3306 -s /sbin/nologin mysql && mkdir /mariadb/3306/data -p \
   && chown -R mysql.mysql /mariadb/

#Download mariadb5.5.60 package
ADD http://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-5.5.60/bintar-linux-x86_64/mariadb-5.5.60-linux-x86_64.tar.gz .
#http://mirrors.neusoft.edu.cn/mariadb//mariadb-5.5.60/bintar-linux-x86_64/mariadb-5.5.60-linux-x86_64.tar.gz
#Unzip
RUN tar xf mariadb-5.5.60-linux-x86_64.tar.gz -C /usr/local/ \
  && rm -f mariadb-5.5.60-linux-x86_64.tar.gz \
  && cd /usr/local/ && ln -sv mariadb-5.5.60-linux-x86_64/ mysql \
  && cd mysql/ && chown -R mysql.mysql ./* \
  && chown -R mysql.mysql /usr/local/mysql
#Initialization
#RUN /usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/mariadb/3306/data/
#Config file
RUN cd /usr/local/mysql && /usr/bin/cp support-files/my-large.cnf /etc/my.cnf \
  && sed -i '/thread_concurrency = 8/adatadir = /mariadb/3306/data/\ninnodb_file_per = on\nskip_name_resolve = on' /etc/my.cnf \
  && /usr/bin/cp support-files/mysql.server /etc/rc.d/init.d/mariadb \
  && chmod +x /etc/rc.d/init.d/mariadb \
  && touch /var/log/mariadb.log && chown mysql.mysql /var/log/mariadb.log \
  && chkconfig --add mariadb
#expose
EXPOSE 3306
ADD mariadb/start.sh  /opt/startup.sh
RUN chmod +x /opt/startup.sh
CMD ["/bin/bash","/opt/startup.sh"]
EOF
echo -e "\033[31;32m================创建php Dockerfile===========\033[0m"
cat>php/Dockerfile<<EOF
###  Set the base image to CentOS
FROM centos

#File Author / Maintainer
MAINTAINER caomuzhong www.logmm.com

#Install necessary tools
RUN yum install -y epel-release bzip2-devel openssl-devel gnutls-devel gcc gcc-c++ cmake libmcrypt-devel libmcrypt ncurses-devel bison-devel libaio-devel openldap  openldap-devel autoconf bison libxml2-devel libcurl-devel libevent libevent-devel gd-devel  expat-devel

#ADD http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz .
#RUN tar xf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8 && ./configure && make && make install

#Create dir the same for nginx's root dir
RUN  mkdir -p /usr/local/nginx/html
#Install PHP7.2.7
ADD http://cn.php.net/distributions/php-7.2.7.tar.gz .
RUN tar xf php-7.2.7.tar.gz && rm -f php-7.2.7.tar.gz && groupadd -g 3306 mysql && useradd -g 3306 -u 3306 -s /sbin/nologin mysql && groupadd -g 1080 www && useradd  -g 1080 -u 1080 -s /sbin/nologin www \
    && cd php-7.2.7 \
    && ./configure  --prefix=/usr/local/php7 \
        --with-config-file-path=/etc/php7 \
        --with-config-file-scan-dir=/etc/php7.d \
        --with-mysqli=mysqlnd  \
        --with-pdo-mysql=mysqlnd \
        --with-iconv-dir \
        --with-freetype-dir \
        --with-jpeg-dir \
        --with-png-dir \
        --with-zlib \
        --with-bz2 \
        --with-libxml-dir \
        --with-curl \
        --with-gd \
        --with-openssl \
        --with-mhash  \
        --with-xmlrpc \
        --with-pdo-mysql \
        --with-libmbfl \
        --with-onig \
        --with-pear \
        --enable-xml \
        --enable-bcmath \
        --enable-shmop \
        --enable-sysvsem \
        --enable-inline-optimization \
        --enable-mbregex \
        --enable-fpm \
        --enable-mbstring \
        --enable-pcntl \
        --enable-sockets \
        --enable-zip \
        --enable-soap \
        --enable-opcache \
        --enable-pdo \
        --enable-mysqlnd-compression-support \
        --enable-maintainer-zts  \
        --enable-session \
        --with-fpm-user=www \
        --with-fpm-group=www  && make -j 2  && make -j 2 install && yum clean all
#Config file
RUN mkdir /etc/php7{,.d}
RUN cd php-7.2.7 && cp php.ini-production  /etc/php7/php.ini \
    && cp sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm && chmod +x /etc/rc.d/init.d/php-fpm && chkconfig --add php-fpm
RUN sed -i '/post_max_size/s/8/16/g;/max_execution_time/s/30/300/g;/max_input_time/s/60/300/g;s#\;date.timezone.*#date.timezone \= Asia/Shanghai#g' /etc/php7/php.ini
RUN cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf \
    && cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf \
    && sed -i -e 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/php7/etc/php-fpm.d/www.conf
#EXPOSE
EXPOSE 9000
#Start php-fpm
ENTRYPOINT ["/usr/local/php7/sbin/php-fpm", "-F", "-c", "/etc/php7/php.ini"]

EOF
echo -e "\033[31;32m=======================================================================\033[0m"
echo -e "\033[31;32m          构建镜像的命令（建议打开多个终端同时执行以下命令）           \033[0m"
echo -e "\033[31;32m构建nginx镜像：docker build -t centos_nginx -f nginx/Dockerfile .      \033[0m"
echo -e "\033[31;32m构建mariadb镜像：docker build -t centos_mariadb -f mariadb/Dockerfile . \033[0m"
echo -e "\033[31;32m构建php镜像：docker build -t centos_php -f php/Dockerfile .             \033[0m"
echo -e "\033[31;32m=======================================================================\033[0m"
