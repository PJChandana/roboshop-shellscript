#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-03ceb08bf2c630ec0 
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do 
    if [ $i == "mongodb" ] || [ $i == "mysql"] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

     IP_ADDRESS=$(ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-03ceb08bf2c630ec0 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instance[0].PrivateIpAddress' --output text
     echo "$i: $IP_ADDRESS"
done