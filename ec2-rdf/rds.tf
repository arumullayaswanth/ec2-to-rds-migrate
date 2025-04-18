##########################
# 3.Security Group
##########################

# Security Group for RDS
resource "aws_security_group" "mysql" {
  name = "mysql-sg"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs. For production, restrict access to trusted IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysql-securitygroup"
  }
}

##########################
# 4. RDS Subnet Group
##########################

# Create a DB Subnet Group using the provided subnets
resource "aws_db_subnet_group" "sub_grps" {
  name        = "my-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids  = ["subnet-08e57414876f5a8fd", "subnet-0fc647877ade39915", "subnet-04b10996d01f4176e"]  # Provided subnet IDs

  tags = {
    Name = "my-db-subnet-group"
  }
}

##########################
# 5. RDS MySQL Instance
##########################
# RDS instance creation using the subnet group
resource "aws_db_instance" "example" {
  identifier            = "my-rds-db"  # <-- DB Identifier added
  allocated_storage    = 20  # In GB
  storage_type         = "gp2"  # General Purpose SSD
  engine               = "mysql"  # Use "postgres", "oracle", etc., if needed
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"  # Choose instance size
  db_name              = "mydatabase"
  username             = "admin"
  password             = "Yaswanth123reddy"  # Use a strong password
  port                 = 3306
  db_subnet_group_name = aws_db_subnet_group.sub_grps.name  # Reference the DB subnet group

  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.mysql.id]

  # Optional parameters
  multi_az             = false
  availability_zone          = "us-east-1a"
  publicly_accessible  = true
  backup_retention_period = 7
  tags = {
    Name = "MyRDS-Instance"
  }
}
