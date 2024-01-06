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
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "rabbitmq download"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "rabbitmq config"
dnf install rabbitmq-server -y &>>LOGFILE
VALIDATE $? "rabbitmq installation" 
systemctl enable rabbitmq-server &>>LOGFILE
VALIDATE $? "rabbitmq enable"
systemctl start rabbitmq-server &>>LOGFILE
VALIDATE $? "rabbitmq start" 
rabbitmqctl add_user roboshop roboshop123 &>>LOGFILE
VALIDATE $? "user adding"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>LOGFILE
VALIDATE $? "permission setting"
