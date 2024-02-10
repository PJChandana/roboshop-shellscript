#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.daws76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "Loading erlang server"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "Loadingrabbitmq server"

dnf install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server  &>> $LOGFILE

VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server  &>> $LOGFILE

VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123  &>> $LOGFILE

VALIDATE $? "Loading rabbitmq data"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE

VALIDATE $? "Loading rabbitmq permissions"

