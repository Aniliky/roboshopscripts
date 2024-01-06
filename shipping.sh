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
dnf install maven -y &>> $LOGFILE
VALIDATE $? "maven app install"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "USER CREATED"
else
    echo "user already exist" 
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "dirrectory making"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE  
VALIDATE $? "downloading the app code to directory"

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping files"

cd /app

mvn clean package &>> $LOGFILE
VALIDATE $? "clean package"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moving files"

cp /home/centos/roboshopscripts/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying files"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "loading service"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "mqsql install"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading schema"
systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restart shipping"