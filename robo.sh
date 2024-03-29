#!/bin/bash
AMI=ami-0f3c7d07486cad139
SG_ID="sg-01fa613612a1de147"
INSTANCE=("mongodb" "redis" "cart" "catalogue" "mysql" "payment" "rabbitmq" "shipping" "user" "web")
ZONE_ID=Z020229810JX6XDJN6ZCK
DOMAIN_NAME="anilroboshop.online"

for i in "${INSTANCE[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    PRIVATE_IP=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $PRIVATE_IP"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$PRIVATE_IP'"
            }]
        }
        }]
    }
    '
done