#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "this script is started runnig at $TIMESTAMP"
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R failed $N"
        exit 1
    else
        echo -e "$2 is $G success $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$Y run this as root user $N"
    exit 1
else
    echo -e "$G your are a root user $N"
fi
dnf install nginx -y &>> LOGFILE
VALIDATE $? "nginx install"
systemctl enable nginx &>> LOGFILE
VALIDATE $? "nginx enable"
systemctl start nginx &>> LOGFILE
VALIDATE $? "nginx start"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> LOGFILE
VALIDATE $? "download web app"
cd /usr/share/nginx/html &>> LOGFILE
unzip -o /tmp/web.zip &>> LOGFILE
VALIDATE $? "unzipping"
cp /home/centos/roboshopscripts/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> LOGFILE
VALIDATE $? "web copying"
systemctl restart nginx &>> LOGFILE
VALIDATE $? "nginx restart"
