#!/bin/bash
#By 我本戏子 2017.6
#changelog:
#1.1添加开机自启动功能
#1.2修改pip获取方式
#1.3考虑到精简版系统的情况，自动安装wget与net-tools
#1.41抛弃Django自带的webserver，使用主流的Nginx+Gunicorn方案，延长爬虫与Mysql连接的超时时间
python -V          
systemctl stop firewalld.service  
systemctl disable firewalld.service   
systemctl stop iptables.service  
systemctl disable iptables.service
setenforce 0  
sed -i s/"enforcing"/"disabled"/g  /etc/selinux/config
yum -y install wget net-tools unzip git
#如果使用linode主机，请取消下面4行的注释
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyuncs.com/repo/Centos-7.repo
#wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#yum clean metadata
#yum makecache
yum -y install gcc gcc-c++ python-devel
mkdir -p /www/wwwroot
cd /www/wwwroot
git clone https://github.com/midoks/ossbc.git
chmod +x /www/wwwroot/ssbc/bin/ssbc-reboot.sh 
cd /www/wwwroot/ssbc
yum -y install epel-release 
yum -y install  python-pip
pip install -r requirements.txt
pip install  pygeoip
mysql -uroot  -e"create database ssbc default character set utf8;"  
mkdir  -p  /data/bt/index/db /data/bt/index/binlog  /tem/downloads
chmod  755 -R /data
chmod  755 -R /tem
yum -y install unixODBC unixODBC-devel postgresql-libs
wget http://sphinxsearch.com/files/sphinx-2.2.9-1.rhel7.x86_64.rpm
rpm -ivh sphinx-2.2.9-1.rhel7.x86_64.rpm
# ------
searchd --config ./sphinx.conf
python manage.py makemigrations
python manage.py migrate
indexer -c sphinx.conf --all 
ps aux|grep searchd|awk '{print $2}'|grep -v grep|xargs kill -9
searchd --config ./sphinx.conf


ln -s /usr/lib/python2.7/site-packages/django/contrib/admin/static/admin /www/wwwroot/ssbc/web/static/admin
cd /www/wwwroot/ssbc
sed -i "42a\    'gunicorn'," /www/wwwroot/ssbc/settings.py
#gunicorn启动网站并在后台运行
nohup gunicorn ssbc.wsgi:application -b 127.0.0.1:8000 --reload>/dev/zero 2>&1&  
myip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
while true; do
    read -p "确定浏览器能访问网站  http://$myip  吗?[y/n]" yn
    case $yn in
        [Yy]* ) cd workers; break;;
        [Nn]* ) exit;;
        * ) echo "请输入y 或 n";;
    esac
done
#运行爬虫并在后台运行
nohup python simdht_worker.py >/dev/zero 2>&1&
#定时索引并在后台运行
nohup python index_worker.py >/dev/zero 2>&1&  
cd /www/wwwroot/ssbc
python manage.py createsuperuser
#开机自启动
chmod +x /etc/rc.d/rc.local

echo "cd /www/wwwroot/ssbc" >> /etc/rc.d/rc.local
echo "indexer -c sphinx.conf --all" >> /etc/rc.d/rc.local
echo "searchd --config ./sphinx.conf " >> /etc/rc.d/rc.local
echo "nohup gunicorn ssbc.wsgi:application -b 127.0.0.1:8000 --reload>/dev/zero 2>&1&" >> /etc/rc.d/rc.local
echo "cd /www/wwwroot/ssbc/workers" >> /etc/rc.d/rc.local
echo "nohup python simdht_worker.py >/dev/zero 2>&1&" >> /etc/rc.d/rc.local
echo "nohup python index_worker.py >/dev/zero 2>&1&" >> /etc/rc.d/rc.local
#Crontab setup
echo "setup crontab for ssbc reboot"
crontab -l > mycron
echo "*/15 * * * * sh /www/wwwroot/ssbc/bin/ssbc-reboot.sh" >> mycron
crontab mycron
rm mycron
echo "setup crontab finished"
