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
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "CATALOGUE DOWNLOADED"
cd /app 
unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "CATALOGUE UNZIPPING"
cd /app
npm install &>> $LOGFILE
VALIDATE $? "DEPENDENCIES INSTALLATION"
cp /home/centos/roboshopscripts/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "CATALOGUE COPYING"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "DAEMON-RELOAD"
systemctl enable catalogue &>> $LOGFILE
systemctl start catalogue &>> $LOGFILE
VALIDATE $? "CATALOGUE START"
cp /home/centos/roboshopscripts/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "MONOGREPO COPYING"
dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "MONGODB INSTALLAION"
mongo --host mongodb.anilroboshop.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalouge data into MongoDB"