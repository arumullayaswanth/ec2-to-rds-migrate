provider "aws" {
  region = "us-east-1"
}

##########################
# 1. VPC and Networking
##########################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

##########################
# 2. Security Group
##########################

resource "aws_security_group" "mysql_sg" {
  name   = "mysql-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Open to all — use cautiously
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

##########################
# 3. RDS Subnet Group
##########################

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "MySQL Subnet Group"
  }
}

##########################
# 4. RDS MySQL Instance
##########################

resource "aws_db_instance" "mysql" {
  identifier              = "my-sqlserver-db"
  engine                  = "mysql"
  engine_version          = "8.0.35"  # latest available
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "Yaswanth123reddy"
  db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mysql_sg.id]
  publicly_accessible     = true
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = {
    Name = "MySQL-RDS-Instance"
  }
}


##########################
# 5. EC2 Security Group
##########################

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for testing - restrict in prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-07a6f770277670015"  # Amazon Linux 2 AMI (Check region)
  instance_type          = "t2.micro"
  key_name               = "my-Key pair" # The name of the key pair.
  availability_zone = "us-east-1a" # Availability Zone for the instance.
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

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
