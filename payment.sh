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
dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "python36 installing"
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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "payment app download"
cd /app 
unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "pip3 install"

cp /home/centos/roboshopscripts/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying files"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "app reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "payment start"



