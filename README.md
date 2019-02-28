# Challenge

This script to build an Ubuntu instance on AWS and install Prometheus, Grafana & Graphite. 
### Description 
This script does: 
1. Create key pair
2. Create a Security Group with proper setup to allow connection to Prometheus, Grafana & Graphite. 
3. Create an EC2 instance in the created Security Group
4. Output the Public IP Address of the EC2 Ubuntu instance created and 
5. SCP the tar.gz file with a deploy script to install Prometheus, Grafana & Graphite. 

Untar it on a a local directory and run ./build.sh. 

### Getting Started 
##### Dependencies and Assumptions
1. awscli is required to run this script (awscli can also have been installed on a virtualenv). 
See https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html on how to install awscli on Linux. 
2. An AWS account is required to run create the EC2 instance and 
3. 'aws configure' command must be run (or been run previously) with credentials for an IAM user with AdministratorAccess privileges. 
4. A VPC with a Public subnet is required prior running the script
5. The AWS region is hardcoded as eu-west-1 (Ireland). Feel free to change it to what works best for you. 

##### Installing 
```sh
cd ~
git clone https://github.com/MeirDukhan/challenges.git
```

#### Executing Program

The following environment variables are required to run the script: 
```sh 
# Assuming there is an already existing public subnet (i.e. a subnet with access to Internet)
# VPC_ID – a VPC with a public subnet-id 
export VPC_ID=<your vpc-id>

# SUBNET_ID – a public subnet-id
export SUBNET_ID=<your public-subnet-id>

cd ~/challenges
./build.sh 
ssh -i ~/.ssh/challenge-keypair.pem ubuntu@<ip-of-instance> 
tar xvf Challenge.tar.gz
./deploy.sh 

```

License
----

MIT


