# Create VPC resources
# VPC, subnet, igw, routing table

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_tag
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_tag
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_tag
  }
}

resource "aws_default_route_table" "default_route" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = var.internet_gateway_tag
  }
}

#S3 and Policies

resource "aws_iam_role" "ec2_iam_role" {
  name               = var.ec2_role_name
  assume_role_policy = var.ec2-trust-policy
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_iam_role.id
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  name   = var.ec2_role_policy_name
  role   = aws_iam_role.ec2_iam_role.id
  policy = var.ec2-s3-permissions
}

resource "aws_s3_bucket" "s3" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

#User's Public IP and add to Security Group

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# Create Security Group

resource "aws_security_group" "jenkins_security_group" {
  name        = var.security_group_name
  description = "Apply to Jenkins EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow access to Jenkins from My IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Jenkins_Security_Group"
  }
}

# Create EC2

resource "aws_instance" "jenkins_instance" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.ssh_key_name
  subnet_id            = aws_subnet.subnet.id
  security_groups      = [aws_security_group.jenkins_security_group.id]
  user_data            = var.ec2_user_data

  tags = {
    Name = var.ec2_tag
  }
}
