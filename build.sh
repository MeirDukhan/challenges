#!/bin/sh 

# Get aws cli environment 
if [ ! -x /bin/aws ] ; then 
   . ~/venv_aws/bin/activate 
fi 

# Global variables
REGION='eu-west-1' 
KEYPAIR_NAME='challenge-keypair'
#VPC_ID='vpc-d1af18b6'
#SUBNET_ID='subnet-c3cb7a8a'
GROUP_NAME='Challenge_SG' 
IMAGE_ID='ami-09f0b8b3e41191524'
INSTANCE_TYPE='t2.micro'


#echo '$AWS_PROFILE= ' $AWS_PROFILE
#echo '$AWS_SECRET_ACCESS_KEY = ' $AWS_SECRET_ACCESS_KEY
#echo '$AWS_ACCESS_KEY = ' $AWS_ACCESS_KEY

#if [ -z $AWS_PROFILE ] ; then 
#    echo "AWS_PROFILE is empty. Please provide a profile with IAM AdministratorAccess privileges. " 
#    echo "export AWS_PROFILE=<your AWS_PROFILE>." 
#    #exit 1 
#fi 

#if [ -z $AWS_SECRET_ACCESS_KEY ] ; then 
#    echo "AWS_SECRET_ACCESS_KEY is empty." 
#    echo "export AWS_SECRET_ACCESS_KEY=<your AWS_SECRET_ACCESS_KEY>." 
#    #exit 2 
#fi 

#if [ -z $AWS_ACCESS_KEY ] ; then 
#    echo "AWS_ACCESS_KEY is empty." 
#    echo "export AWS_ACCESS_KEY=<your AWS_ACCESS_KEY>." 
#    #exit 3 
#fi 

if [[ -z $VPC_ID || -z $SUBNET_ID ]] ; then 
    echo "Either VPC_ID or SUBNET_ID is empty. Please provide both. Thanks" 
    echo "export VPC_ID=<vpc-id> ; export SUBNET_ID=<a PUBLIC subnet-id>" 
    exit 4 
fi 


# Step 1: Create key pair
rm -f ~/.ssh/$KEYPAIR_NAME.pem
aws ec2 create-key-pair --key-name $KEYPAIR_NAME --region $REGION --query 'KeyMaterial' --output text > ~/.ssh/$KEYPAIR_NAME.pem
chmod 400 ~/.ssh/$KEYPAIR_NAME.pem

# Step 2: Create a Security Group
SG_ID=$(aws ec2 create-security-group --description "Challenge SG" --group-name $GROUP_NAME --vpc-id $VPC_ID --output text --region $REGION) 

MY_IP=$(curl ipinfo.io/ip) 
# Inboud rules: allow SSH from my ip address, HTTPD (Graphite), Prometheus & Grafana, 80, 9090 & 3000 resp.
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr $MY_IP/32 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 9090 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3000 --cidr 0.0.0.0/0 --region $REGION

# Outbound rules: HTTP HTTPS 
# Remove the allow-all egress rule 
aws ec2 revoke-security-group-egress --group-id $SG_ID --protocol all --port all --cidr 0.0.0.0/0 --region $REGION

# Allow HTTP & HTTPS
aws ec2 authorize-security-group-egress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-egress --group-id $SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $REGION

# Step 3: Create an EC2 instance in the created Security Group 
aws ec2 run-instances --image-id $IMAGE_ID --security-group-ids $SG_ID --subnet-id $SUBNET_ID --instance-type $INSTANCE_TYPE --associate-public-ip-address --key-name $KEYPAIR_NAME --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cli-generated}]' --region $REGION > run-instances.json 

# Step 4: Wait 90 sec to get the instance up & running, so we can fetch its public IP address
sleep 90
instance_id=$(grep InstanceId  run-instances.json | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g') 

# Fetch public IP address of launched instance
PublicIP=$(aws ec2 describe-instances --instance-ids $instance_id --region $REGION | grep PublicIpAddress | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g') 

#echo "Connect to http://$PublicIP:9090 for Prometheus" 
#echo "Connect to http://$PublicIP:3000 for Grafana" 
#echo "Connect to http://$PublicIP for Graphite" 

echo "SCP the deploy tar file to $PublicIP" 
scp -i ~/.ssh/$KEYPAIR_NAME.pem -o StrictHostKeyChecking=no Challenge.tar.gz ubuntu@$PublicIP:/home/ubuntu

echo "Connect to your AWS console. Go to EC2 instance. Get the plublic IP address." 
echo "Then login via: ssh -i ~/.ssh/$KEYPAIR_NAME.pem ubuntu@$PublicIP" 
echo "When logged in, run: " 
echo -e "\t\t tar xvf Challenge.tar.gz" 
echo -e "\t\t ./deploy.sh" 


