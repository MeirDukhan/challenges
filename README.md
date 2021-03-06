# Challenge

This script build an Ubuntu instance on AWS and install Prometheus, Grafana & Graphite. 

### Description 
This script does the following 
1. Create key pair to access the EC2 Ubuntu instance 
2. Create a Security Group with proper setup to allow:

  - SSH **only** from the machine running this script
  - Connection to Prometheus on port 9090 from everywhere
  - Connection to Grafana on port 3000 from everywhere
  - Connection to Graphite on port 80 from everywhere

3. Create a t2.micro Ubuntu E2 instance in the created Security Group
4. Output the Public IP Address of the EC2 Ubuntu instance created and 
5. SCP the tar.gz file to the EC2 created instance. 
This tar.gz file contain a deploy script to install Prometheus, Grafana & Graphite. 

The initial challenge was to setup Grafana so it includes a dashboard that displays the **memory, CPU and disk usage** of the VM.
However, I was unable to add a Prometheus datastore, so that in fact, Grafana is not doing very useful stuff... 
I suspect the Grafana version I choose but it has to be clarified. 

### Getting Started 
##### Dependencies and Assumptions
1. **awscli** is required to run this script (awscli can also have been installed on a virtualenv). 
See https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html on how to install awscli on Linux. 
2. An AWS account is required to run create the EC2 instance and 
3. **'aws configure'** command must be run (or been run previously) with credentials for an IAM user with **AdministratorAccess** privileges. 
4. **A VPC with a Public subnet** is required prior running the script
5. The AWS region is hardcoded as **eu-west-1** (Ireland). Feel free to change it to what works best for you. 

##### Installing 
```sh
cd ~
git clone https://github.com/MeirDukhan/challenges.git
```

#### Executing the build script

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


