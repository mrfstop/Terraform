# Variables for main

# VPC variables

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tag" {
  description = "Name tag for VPC"
  type        = string
  default     = "W20-VPC"
}

variable "subnet_tag" {
  description = "Name tag for Subnet"
  type        = string
  default     = "W20-Subnet"
}

variable "subnet_cidr" {
  description = "Subnet cidr block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "internet_gateway_tag" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = "W20-Internet-Gateway"
}

# IAM Role Variables

variable "ec2_role_name" {
  description = "IAM role name for Jenkins EC2"
  type        = string
  default     = "Jenksins_EC2_Server_IAM_Role"
}

variable "ec2_instance_profile_name" {
  description = "IAM instance profile name for Jenkins EC2"
  type        = string
  default     = "Jenkins_EC2_Server_Instance_Profile"
}

variable "ec2_role_policy_name" {
  description = "IAM role policy name for Jenkins EC2"
  type        = string
  default     = "Jenkins_EC2_Role_Policy"
}

variable "ec2-trust-policy" {
  description = "sts assume role policy for EC2"
  type        = string
  default     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }   
    ]
}
EOF  
}

variable "ec2-s3-permissions" {
  description = "IAM permissions for EC2 to S3"
  type        = string
  default     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# S3 Variables

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "w20bucket"
}

# Security Group

variable "security_group_name" {
  description = "Name for Security Group"
  type        = string
  default     = "Week 20 Security Group"
}

# EC2

variable "ami" {
  description = "EC2 AMI"
  type        = string
  default     = "ami-0dfcb1ef8550277af"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "SSH Key for EC2"
  type        = string
  default     = "Week20"
}

variable "ec2_user_data" {
  description = "User data script for EC2"
  type        = string
    default     = <<EOF
#!/bin/bash
# Install Jenkins and Java 
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
# Add required dependencies for the jenkins package
sudo amazon-linux-extras install -y java-openjdk11 
sudo yum install -y jenkins
sudo systemctl daemon-reload

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Firewall Rules
if [[ $(firewall-cmd --state) = 'running' ]]; then
    YOURPORT=8080
    PERM="--permanent"
    SERV="$PERM --service=jenkins"

    firewall-cmd $PERM --new-service=jenkins
    firewall-cmd $SERV --set-short="Jenkins ports"
    firewall-cmd $SERV --set-description="Jenkins port exceptions"
    firewall-cmd $SERV --add-port=$YOURPORT/tcp
    firewall-cmd $PERM --add-service=jenkins
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
fi
EOF
}


variable "ec2_tag" {
  description = "Tag for EC2"
  type        = string
  default     = "Jenkins_Server"
}