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
dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "disabling mysql"
cp /home/centos/roboshopscripts/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "copying sql repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "installing mysql"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "mysql enabling"
systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting passwords"

mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "checking password"

