# Provider configuration
provider "aws" {
  region = "us-east-1"  # Set the region as per your requirement
}

##########################
# 1. Ec2 security group
##########################
# Create a security group allowing all traffic (for testing purposes)
resource "aws_security_group" "allow_all_traffic" {
  name_prefix = "database-securitygroup"
  description = "Allow all inbound and outbound traffic"

# Define an ingress rule for SSH (port 22) allowing access from anywhere (0.0.0.0/0).
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define an ingress rule for HTTP (port 80) allowing access from anywhere (0.0.0.0/0).
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs. For production, restrict access to trusted IPs
  }

  # Define an egress rule allowing all outbound traffic (all ports and protocols).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" signifies all protocols.
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "database-securitygroup"
  }
}

##########################
# 2. EC2 instance
##########################

# Create EC2 instance
resource "aws_instance" "web" {
  ami                    = "ami-07a6f770277670015"  # Amazon Linux 2 AMI (Check region)
  instance_type          = "t2.micro"
  key_name               = "my-Key pair"  # The name of the key pair.
  availability_zone      = "us-east-1a"    # Availability Zone for the instance.
  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]  # Reference the correct security group

  # User data script to install MySQL
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              wget https://repo.mysql.com/mysql80-community-release-el7-5.noarch.rpm
              sudo yum install mysql80-community-release-el7-5.noarch.rpm -y
              sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
              sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql
              sudo yum makecache
              sudo yum install mysql-community-server -y
              sudo systemctl start mysqld
              sudo systemctl enable mysqld
              EOF

  tags = {
    Name = "database-mysql"
  }
}
