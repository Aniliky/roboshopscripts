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
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "REDIS APP DOWNLOAD"
dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "REDIS ENABLE"
dnf install redis -y &>> $LOGFILE
VALIDATE $? "REDIS INSTALL"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "ALLOWING REMOTE ACCESS"
systemctl enable redis &>> $LOGFILE
VALIDATE $? "REDIS ENABLE"
systemctl start redis &>> $LOGFILE
VALIDATE "REDIS START"