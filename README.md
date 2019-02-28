# Kaltura Challenge

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
1. awscli is required (can also been installed on a virtualenv). 
See https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html on how to install awscli on Linux. 
2. An AWS account is required to run create the EC2 instance
3. A VPC with a Public subnet is required prior running the script
3. The AWS region is hardcoded as eu-west-1 (Ireland). Feel free to change it to what works best for you. 

##### Installing 
```sh
mkdir ~/tmp/
git clone <kaltura-challenge.git Path> 
```

#### Executing Program

The following environment variables are required to run the script: 
```sh 
# AWS_PROFILE. The profile to use. It must be an IAM user with AdministratorAccess privilege.
# AWS_SECRET_ACCESS_KEY for the above user.
export AWS_SECRET_ACCESS_KEY=<user AWS_SECRET_ACCESS_KEY> 
# AWS_ACCESS_KEY for the above user.
export AWS_ACCESS_KEY=< user AWS_ACCESS_KEY> 
# Assuming there is an already existing public subnet (i.e. a subnet with access to Internet)
# VPC_ID – a VPC with a public subnet-id 
export VPC_ID=<your vpc-id>
# SUBNET_ID – a public subnet-id
export SUBNET_ID=<your public-subnet-id>

cd ~/tmp/
./build.sh 
```

License
----

MIT


