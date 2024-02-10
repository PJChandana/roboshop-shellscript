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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app


unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping the shipping"
cd /app
mvn clean package &>> $LOGFILE

VALIDATE $? "cleaning the package"


mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Unzipping the shipping"

cp /home/centos/roboshop-shellscript /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying the shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "installing daemon reload"

systemctl start shipping &>> $LOGFILE

VAIDATE $? "Starting shipping" 

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting shipping"
