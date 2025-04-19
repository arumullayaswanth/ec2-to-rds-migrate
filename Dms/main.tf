provider "aws" {
  region = "us-east-1"
}


##########################
# 6. DMS Replication Instance
##########################


# Create a DMS replication instance
resource "aws_dms_replication_instance" "dms_replication_instance" {
  replication_instance_id         = "my-dms-instance"
  replication_instance_class      = "dms.t3.medium"
  # description                     = "Create a replication instance for AWS DMS"
  allocated_storage               = 10
  publicly_accessible             = true
  auto_minor_version_upgrade      = true
  apply_immediately               = true
  engine_version                  = "3.5.3"  # Ensure this version is valid for your setup

  tags = {
    Name = "my-dms-replication-instance"
  }
}

##########################
# 7. DMS Source Endpoint (EC2 MySQL)
##########################

resource "aws_dms_endpoint" "source_endpoint" {
  endpoint_id     = "SourceEndpoint-ec2"
  endpoint_type   = "source"
  engine_name     = "mysql"
  username        = "root"
  password        = "Admin@123"
  port            = 3306
  server_name     = "ec2-18-208-226-187.compute-1.amazonaws.com"     #it is manual process you have to go to your database instance(database-mysql)-->copy Public IPv4 DNS--->paste here
  depends_on      = [aws_dms_replication_instance.dms_replication_instance]

  tags = {
    Name = "SourceEndpoint-ec2"
  }
}

##########################
# 8. DMS Target Endpoint (RDS)
##########################
#The required IAM role dms-cloudwatch-logs-role does not exist. 
#This role allows DMS to publish logs to Amazon CloudWatch. 
#Go to IAM console to create this role with required permissions.

resource "aws_dms_endpoint" "target_endpoint" {
  endpoint_id     = "rds-targetendpoint"
  endpoint_type   = "target"
  engine_name     = "mysql"
  username        = "admin"
  password        = "Yaswanth123reddy"
  port            = 3306
  server_name     = "my-rds-db.c0n8k0a0swtz.us-east-1.rds.amazonaws.com"  #databade end point
  depends_on      = [aws_dms_replication_instance.dms_replication_instance]

  tags = {
    Name = "TargetEndpoint"
  }
}

##########################
# 9. DMS Replication Task
##########################

resource "aws_dms_replication_task" "dms_replication_task" {
  replication_task_id           = "My-DMS-Task"
  migration_type                = "full-load-and-cdc"
  replication_instance_arn      = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn
  source_endpoint_arn           = aws_dms_endpoint.source_endpoint.endpoint_arn
  target_endpoint_arn           = aws_dms_endpoint.target_endpoint.endpoint_arn
  replication_task_settings     = file("dms.json")
  table_mappings                = file("table_mappings.json")
  depends_on = [
    aws_dms_replication_instance.dms_replication_instance,
    aws_dms_endpoint.source_endpoint,
    aws_dms_endpoint.target_endpoint
  ]

  tags = {
    Name = "My-DMS-Task"
  }
}
