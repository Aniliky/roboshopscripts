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
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "cart application download"
cd /app 
unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "cart application unzipping"

cd /app 
npm install &>> $LOGFILE
VALIDATE $? "installation of dependencies"
cp /home/centos/roboshopscripts/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "cart service copying"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"
systemctl enable cart &>> $LOGFILE
systemctl start cart &>> $LOGFILE
VALIDATE $? "start"