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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying repo"

dnf instal mongodb-org -y &>> $LOGFILE

VALIDATE $? "MONGODB INSTALLATION"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "MONGODB ENABLE"

systemctl start monogd &>> $LOGFILE
VALIDATE $? "MOGODB START"

sed -i 's/127.0.0.1 to 0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

systemctl restart mongod &>> $LOGFILE