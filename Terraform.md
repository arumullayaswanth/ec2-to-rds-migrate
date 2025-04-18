# 🚀 EC2 to RDS MySQL Migration using Terraform, GitHub, and AWS DMS

## ✅ Step 1: Push Terraform Code to GitHub from VS Code
```bash
cd ~/Downloads
mkdir ec2-to-rds-migrate
cd ec2-to-rds-migrate
git clone https://github.com/arumullayaswanth/ec2-to-rds-migrate.git
cd ec2-to-rds-migrate
ls
```

---

## ✅ Step 2: Create IAM Role for Replication Instance
1. Go to **AWS Console → IAM → Roles → Create Role**
2. **Trusted entity type**: AWS Service
3. **Use case**: DMS
4. **Permissions**: AdministratorAccess
5. **Role Name**: `dms-cloudwatch-log-role`
6. Click **Create Role**

---

## ✅ Step 3: Create IAM Role for Endpoint
1. Again, go to **IAM → Create Role**
2. **Trusted entity**: AWS Service
3. **Use case**: DMS
4. **Permissions**: AdministratorAccess
5. **Role Name**: `dms-vpc-role`
6. Click **Create Role**

---

## ✅ Step 4: Create MySQL Database

### 🔹 1. Launch MySQL RDS Instance
1. Go to the AWS Console.
2. In the Search Bar, type RDS and select it from the dropdown.
3. In the left-side menu of the RDS Dashboard, click **Databases**.
4. Click **Create Database**.
5. Choose **Standard Create**.

---

### 🔹 2. Set Configuration
- **Engine type:** MySQL  
- **Version:** MySQL 8.4.3  
- **Templates:** Free tier  
- **DB Instance Identifier:** `my-sqlserver-db`

### 🔸 Credentials Settings:
- **Master Username:** `admin`  
- **Password Management:** Self-managed  
- **Master Password:** `Yaswanth123reddy`  
- **Confirm Password:** `Yaswanth123reddy`

---

## 🔹 3. Instance & Network Settings
- **DB Instance Class:** `db.t3.micro`  
- **Storage:** 20 GiB  
- **Compute Resources:** Don’t connect to EC2  
- **Network Type:** IPv4  
- **VPC:** Default (`vpc-0b08fcea62cde9567`)  
- **DB Subnet Group:** Default  
- **Public Access:** yes  
- **VPC Security Group:** Choose existing → Select default

Click **Create Database**

---
## ✅ Step 5: Launch Source EC2 Instance
1. Go to **EC2 Console → Launch Instance**
2. Name: `database-source-ec2`
3. AMI: Amazon Linux 2
4. Instance Type: `t2.micro`
5. Key Pair: Choose existing or create new
6. Security Group:
   - Inbound Rule:
     - Type: MySQL/Aurora
     - Port: 3306
     - Source: Your IP
7. Leave storage as default (8 GiB SSD)
8. Launch the instance

---

---

## ✅ Step 6: Connect to EC2 Instance
1. Go to **EC2 → Instances**
2. Select `database-source-ec2`
3. Click **Connect → EC2 Instance Connect** or use SSH

---

## ✅ Step 7: Install and Configure MySQL 8.0 on Source EC2
1. **Update the Package Index**
   ```bash
   sudo su -
   sudo yum update -y
   ```

2. **Download MySQL 8.0 Community Release Package**
   ```bash
   wget https://repo.mysql.com/mysql80-community-release-el7-5.noarch.rpm
   ```

3. **Install MySQL Repository and Import GPG Keys**
   ```bash
   sudo yum install mysql80-community-release-el7-5.noarch.rpm -y
   sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
   sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql
   sudo yum makecache
   ```

4. **Install MySQL Server**
   ```bash
   sudo yum install mysql-community-server -y
   ```

5. **Verify Installation**
   ```bash
   mysql -V
   ```

6. **Start and Enable MySQL**
   ```bash
   sudo systemctl start mysqld
   sudo systemctl enable mysqld
   systemctl status mysqld
   ```

7. **Retrieve Temporary Root Password**
   ```bash
   sudo grep 'password' /var/log/mysqld.log
   ```

8. **Login to MySQL Using the Temporary Password**
   ```bash
   sudo mysql -u root -p
   ```
   🔐 Enter the temporary password from Step 7

9. **Change the Root Password**
   ```bash
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'Yaswanth@123';
   SHOW DATABASES;
   ```
10. **Exit and Re-login with the New Password**
  ```bash
  sudo mysql -u root -p
  ```
  Enter Admin@123 when prompted.
 
11. **Create a New Database and Table**
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

12. **Insert Sample Records**
   ```sql
   INSERT INTO customers (customer_id, first_name, last_name, company, city) VALUES
   ('DD37Cf93aecA6Dc', 'Sheryl', 'Baxter', 'Rasmussen Group', 'East Leonard'),
   ('1Ef7b82A4CAAD10', 'Preston', 'Lozano', 'Vega-Gentry', 'East Jimmychester'),
   ('6F94879bDAfE5a6', 'Roy', 'Berry', 'Murillo-Perry', 'Isabelborough'),
   ('5Cef8BFA16c5e3c', 'Linda', 'Olsen', 'Dominguez, Mcmillan and Donovan', 'Bensonview'),
   ('053d585Ab6b3159', 'Joanna', 'Bender', 'Martin, Lang and Andrade', 'West Priscilla'),
   ('2d08FB17EE273F4', 'Aimee', 'Downs', 'Steele Group', 'Chavezborough');
   ```

13. **Verify Data**
   ```sql
   SELECT * FROM vsv.customers;
   ```

14 **User Table SQL Script**

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

15. **how All Tables**

```sql
SHOW TABLES;
```

---

16. **Insert Sample Data**

> These records assume the table has already been expanded with additional fields like `email`, `phone`, etc. If not, you should alter the table accordingly.

```sql
INSERT INTO user (
    customer_id, first_name, last_name, email, phone, company, city, state, country, postal_code, address_line1, address_line2, is_active
) VALUES 
('CUST1006', 'Aisha', 'Khan', 'aisha.khan@example.com', '+91-9876543210', 'TechNova', 'Mumbai', 'MH', 'India', '400001', '14 Marine Drive', 'Floor 3', TRUE),
('CUST1007', 'Liam', 'O\'Connor', 'liam.oconnor@example.com', '+353-85-1234567', 'GreenFields Ltd.', 'Dublin', NULL, 'Ireland', 'D02 Y006', '25 St. Stephen\'s Green', NULL, TRUE),
('CUST1008', 'Mia', 'López', 'mia.lopez@example.com', '+34-600-123-456', 'SolarTech', 'Barcelona', 'Catalonia', 'Spain', '08001', 'Carrer de Balmes 45', NULL, FALSE),
('CUST1009', 'Noah', 'Kim', 'noah.kim@example.com', '+82-10-1234-5678', 'NeoGen', 'Seoul', NULL, 'South Korea', '04524', '77 Gwanghwamun-ro', NULL, TRUE),
('CUST1010', 'Olivia', 'Nguyen', 'olivia.nguyen@example.com', '+84-90-123-4567', 'VN Digital', 'Ho Chi Minh City', NULL, 'Vietnam', '700000', '100 Nguyen Hue', NULL, TRUE),
('CUST1011', 'Ethan', 'Brown', 'ethan.brown@example.com', '+1-312-555-0198', 'WindyTech', 'Chicago', 'IL', 'USA', '60601', '500 Michigan Ave', 'Suite 301', TRUE),
('CUST1012', 'Sophia', 'Meier', 'sophia.meier@example.com', '+49-170-1234567', 'München Tech', 'Munich', 'Bavaria', 'Germany', '80331', 'Karlsplatz 3', NULL, TRUE),
('CUST1013', 'Lucas', 'Dubois', 'lucas.dubois@example.com', '+33-6-12-34-56-78', 'PariTech', 'Paris', 'Île-de-France', 'France', '75001', '10 Rue de Rivoli', NULL, FALSE),
('CUST1014', 'Chloe', 'Wilson', 'chloe.wilson@example.com', '+1-604-555-0123', 'Maple Systems', 'Vancouver', 'BC', 'Canada', 'V6B 3K9', '808 Granville St', NULL, TRUE),
('CUST1015', 'Jack', 'Taylor', 'jack.taylor@example.com', '+61-3-9123-4567', 'Southern Solutions', 'Melbourne', 'VIC', 'Australia', '3000', '55 Collins St', 'Level 6', TRUE);
```

---

17. **Query the Table**

```sql
SELECT * FROM vsv.user;
```

---



---


# ✅ Step 8: Grant Remote Access and Permissions

1. **Check Existing Users**
```sql
SELECT user, host FROM mysql.user WHERE user = 'root';
```

---

2. **Create Root User for Any Host (if not exists)**
```sql
CREATE USER 'root'@'%' IDENTIFIED BY 'Yaswanth@123';
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

## ✅ Step 9: Copy EC2 Public IPv4 DNS ( Name: database-source-ec2 )
•	Go to EC2 > Instances > database-source-ec2
•	Select your instance → Copy Public IPv4 DNS

---

## ✅ Step 10: Update `main.tf` with Public IPv4 DNS EC2 DNS
```hcl
server_name = "ec2-13-232-36-249.ap-south-1.compute.amazonaws.com"
```

---

## ✅ Step 11: Push Updated Code to GitHub
```bash
git status
git add .
git commit -m "project"
git pull origin master --rebase
git push origin master
```
---
## ✅ Step 12: Run Terraform Commands
```bash
terraform init
terraform plan
terraform apply
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

