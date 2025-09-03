# Provider configuration
provider "aws" {
  region = "us-east-1" # Set the region as per your requirement
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
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs. For production, restrict access to trusted IPs
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
  ami                    = "ami-00ca32bbc84273381" # Amazon Linux 2023 AMI (Check region)
  instance_type          = "t2.micro"
  key_name               = "us-east-1"                               # The name of the key pair.
  availability_zone      = "us-east-1a"                              # Availability Zone for the instance.
  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id] # Reference the correct security group

  # User data script to install MySQL
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo dnf install -y mariadb105-server
              sudo systemctl enable --now mariadb
              mysql -e "CREATE DATABASE IF NOT EXISTS sourcedb;"
              mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'Admin@123';"
              mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
              mysql -e "FLUSH PRIVILEGES;"
              EOF

  tags = {
    Name = "database-mysql"
  }
}


##########################
# 6. IAM Roles for DMS
##########################

resource "aws_iam_role" "dms_cloudwatch_role" {
  name = "dms-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dms.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_role_policy" {
  role       = aws_iam_role.dms_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dms.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}
