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
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "NODEJS DISABLING"
dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "NODEJS:18 ENABLING"
dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "NODEJS INSTALLATION"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "USER CREATED"
else
    echo "user already exist" 
fi
mkdir -p /app &>> $LOGFILE
VALIDATE $? "APP DIRECTORY CREATED"
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
cd /app 
unzip -o /tmp/user.zip
npm install 
cp /home/centos/roboshopscripts/user.service /etc/systemd/system/user.service

systemctl daemon-reload
systemctl enable user
systemctl start user
cp /home/centos/roboshopscripts/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-org-shell -y
mongo --host  </app/schema/user.js
