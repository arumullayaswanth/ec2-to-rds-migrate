# 🚀 EC2 to RDS MySQL Migration using Terraform, GitHub, and AWS DMS

## ✅ Step 1: Push Terraform Code to GitHub from VS Code
```bash
cd 
```
```bash
cd Downloads
```
```bash
mkdir ec2-to-rds-migrate
```
```bash
cd ec2-to-rds-migrate
```
```bash
git clone https://github.com/arumullayaswanth/ec2-to-rds-migrate.git
```
```bash
cd ec2-to-rds-migrate
```
```bash
ls
```
```bash
cd ec2-rds
```
```bash
terraform init
```
```bash
terraform validate
```
```bash
terraform plan
```

```bash
terraform apply -auto-approve
```
**To delete both your EC2 instance and RDS instance using Terraform, you need to  this command**

```bash
terraform destroy -auto-approve
```

---





---

## ✅ Step 6: Connect to EC2 Instance
1. Go to **EC2 → Instances**
2. Select `database-mysql`
3. Click **Connect → EC2 Instance Connect** or use SSH

---

## ✅ Step 7: Install and Configure MySQL 8.0 on Source EC2

1. **Retrieve Temporary Root Password**
   ```bash
   sudo grep 'password' /var/log/mysqld.log
   ```

2. **Login to MySQL Using the Temporary Password**
   ```bash
   sudo mysql -u root -p
   ```
   🔐 Enter the temporary password from Step 7

3. **Change the Root Password**
   ```bash
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'Admin@123';
   SHOW DATABASES;
   ```
4. **Exit and Re-login with the New Password**
  ```bash
  sudo mysql -u root -p
  ```
  Enter Admin@123 when prompted.
 
5. **Create a New Database and Table**
   ```sql
   CREATE DATABASE vsv;
   USE vsv;
   CREATE TABLE customers (
       id INT PRIMARY KEY AUTO_INCREMENT,
       customer_id VARCHAR(255),
       first_name VARCHAR(100),
       last_name VARCHAR(100),
       company VARCHAR(255),
       city VARCHAR(255)
   );
   ```

6. **Insert Sample Records**
   ```sql
   INSERT INTO customers (customer_id, first_name, last_name, company, city) VALUES
   ('DD37Cf93aecA6Dc', 'Sheryl', 'Baxter', 'Rasmussen Group', 'East Leonard'),
   ('1Ef7b82A4CAAD10', 'Preston', 'Lozano', 'Vega-Gentry', 'East Jimmychester'),
   ('6F94879bDAfE5a6', 'Roy', 'Berry', 'Murillo-Perry', 'Isabelborough'),
   ('5Cef8BFA16c5e3c', 'Linda', 'Olsen', 'Dominguez, Mcmillan and Donovan', 'Bensonview'),
   ('053d585Ab6b3159', 'Joanna', 'Bender', 'Martin, Lang and Andrade', 'West Priscilla'),
   ('2d08FB17EE273F4', 'Aimee', 'Downs', 'Steele Group', 'Chavezborough');
   ```

7. **Verify Data**
   ```sql
   SELECT * FROM vsv.customers;
   ```

8 **User Table SQL Script**

# Table Creation

```sql
CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(255),
    city VARCHAR(255)
);
```

---

9. **how All Tables**

```sql
SHOW TABLES;
```

---

10. **Insert Sample Data**

> These records assume the table has already been expanded with additional fields like `email`, `phone`, etc. If not, you should alter the table accordingly.

```sql
INSERT INTO user (customer_id, first_name, last_name, company, city) VALUES
('CUST1001', 'John', 'Doe', 'TechCorp', 'New York'),
('CUST1002', 'Jane', 'Smith', 'InnovateX', 'San Francisco'),
('CUST1003', 'Aidan', 'Brown', 'GlobalTech', 'Los Angeles');

```

---

11. **Query the Table**

```sql
SELECT * FROM vsv.user;
```

---



# ✅ Step 4: Grant Remote Access and Permissions

1. **Check Existing Users**
```sql
SELECT user, host FROM mysql.user WHERE user = 'root';
```

---

2. **Create Root User for Any Host (if not exists)**
```sql
CREATE USER 'root'@'%' IDENTIFIED BY 'Admin@123';
```

---

3. **Grant All Privileges to Root**
```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
```

---

4. **Apply Changes**
```sql
FLUSH PRIVILEGES;
```

---

5. **Optional - Reconfirm Root Password for '%**'
```sql
ALTER USER 'root'@'%' IDENTIFIED BY 'Admin@123';
FLUSH PRIVILEGES;
```
---


## ✅ Step 5: Create IAM Role for Replication Instance
1. Go to **AWS Console → IAM → Roles → Create Role**
2. **Trusted entity type**: AWS Service
3. **Use case**: DMS
4. **Permissions**: AdministratorAccess
5. **Role Name**: `dms-cloudwatch-log-role`
6. Click **Create Role**

---

## ✅ Step 6: Create IAM Role for Endpoint
1. Again, go to **IAM → Create Role**
2. **Trusted entity**: AWS Service
3. **Use case**: DMS
4. **Permissions**: AdministratorAccess
5. **Role Name**: `dms-vpc-role`
6. Click **Create Role**

---

```bash
cd ec2-to-rds-migrate
```
```bash
ls
```
```bash
cd dns
```





## ✅ Step 7: Copy EC2 Public IPv4 DNS ( Name: database-source-ec2 )
•	Go to EC2 > Instances > database-source-ec2
•	Select your instance → Copy Public IPv4 DNS

---

## ✅ Step 8: Update `main.tf` with Public IPv4 DNS EC2 DNS
```hcl
server_name = "ec2-13-232-36-249.ap-south-1.compute.amazonaws.com"
```

---

## ✅ Step 11: Push Updated Code to GitHub
```bash
git status
```
```bash
git add .
```
```bash
git add .
```
```bash
git commit -m "project"
```
```bash
git pull origin master --rebase
git push origin master
```
```bash
git push origin master
```
---
## ✅ Step 12: Run Terraform Commands

```bash
terraform init
```
```bash
terraform validate
```
```bash
terraform plan
```

```bash
terraform apply -auto-approve
```
**To delete both your EC2 instance and RDS instance using Terraform, you need to  this command**

```bash
terraform destroy -auto-approve
```

---

## ✅ Step 13: Start DMS Migration Task
1. Go to **AWS → DMS → Database Migration Tasks**
2. Select your migration task
3. Click **Actions → Restart/Resume**

---

## ✅ Step 14: Get RDS Endpoint
1. Go to **RDS → Databases**
2. Select your DB instance
3. Scroll to **Connectivity & Security**
4. Copy the **Endpoint**

Example:
```
my-sqlserver-dbc0n8k0a0swtz.us-east-1.rds.amazonaws.com
```
---
## ✅ Step 15: Connect to RDS via MySQL Workbench
1. Open **MySQL Workbench**
2. Go to **Database > Manage Connections**
3. Fill in:
   - Connection Name: `AWS MySQL`
   - Hostname: `<RDS endpoint>`ex:`my-sqlserver-dbc0n8k0a0swtz.us-east-1.rds.amazonaws.com` 
   - Port: `3306`
   - Username: `admin`
   - Password: `Yaswanth123reddy`
4. Click **Test Connection**
     - ✅ If successful: “Connection parameters are correct.”  
6. If successful → Click **OK**

---

## ✅ Step 16: Create and Verify Database
```sql
CREATE DATABASE vsv;
USE vsv;
SHOW TABLES;
```
Click ⚡ to execute and verify your tables and data.

