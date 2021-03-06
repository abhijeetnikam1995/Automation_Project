#!/bin/bash

name="abhijeet"
s3_bucket="upgrad-abhijeet"
#this is Automation-v0.1
apt update -y

if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]];
then
    apt install apache2 -y
fi

#running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d'()')
if [[ running != $(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()') ]];
then
     systemctl start apache2
fi
#enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != $(systemctl is-enabled apache2 | grep "enabled") ]];
then
      systemctl enable apache2
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log

file=/tmp/${name}-httpd-logs-${timestamp}.tar
if [ -f "$file" ];
then
     aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://upgrad-abhijeet/${name}-httpd-logs-${timestamp}.tar
fi

path="/var/www/html"
if [ ! -f ${path}/inventory.html ];
then
    echo -e 'Log Type\t-\tTime Created\t-\tFile Type\t-\tFile Size' > /var/www/html/inventory.html
fi
if [[ -f ${path}/inventory.html ]];
then
    size=$(du -h /tmp/${name}-httpd-logs-*.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${path}/inventory.html
fi
if [[ ! -f /etc/cron.d/Automation ]];
then
    echo " * * * * * root/Automation_Project/Automation.sh" >> /etc/cron.d/Automation
fi

