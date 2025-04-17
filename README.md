## ✅ Step 1: Launch the Source EC2 Instance
1. Go to EC2 Console → Click on "Launch Instance"
2. **Name and Tags**
   - Name: `database-source-ec2`
3. **Application and OS Images (AMI)**
   - Select: `Amazon Linux 2 AMI (HVM) – Kernel 5.10, SSD Volume Type`
4. **Instance Type**
   - Choose: `t2.micro (Free Tier eligible)`
5. **Key Pair (Login)**
   - Choose your key pair: `my-key-pair`
6. **Network Settings**
   - Select Allow all traffic (Security Group)
   - Or manually Add Inbound Rule:
     - Type: MySQL/Aurora
     - Protocol: TCP
     - Port Range: 3306
     - Source: Your IP (or specific IP range)
7. **Configure Storage**
   - Leave default (8 GiB General Purpose SSD)
8. **Launch Instance**

---

## ✅ Step 2: Connect to the Instance
1. Go to the Instances page in the EC2 dashboard
2. Select the `database-source-ec2` instance
3. Click Connect → Choose EC2 Instance Connect or SSH with `.pem` key

---

## ✅ Step 3: Install and Configure MySQL 8.0 on Source EC2
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

8. **Login and Change Password**
   ```bash
   sudo mysql -u root -p
   # Enter temporary password
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'Yaswanth@123';
   SHOW DATABASES;
   ```

9. **Create Database and Table**
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

10. **Insert Sample Records**
   ```sql
   INSERT INTO customers (customer_id, first_name, last_name, company, city) VALUES
   ('DD37Cf93aecA6Dc', 'Sheryl', 'Baxter', 'Rasmussen Group', 'East Leonard'),
   ('1Ef7b82A4CAAD10', 'Preston', 'Lozano', 'Vega-Gentry', 'East Jimmychester'),
   ('6F94879bDAfE5a6', 'Roy', 'Berry', 'Murillo-Perry', 'Isabelborough'),
   ('5Cef8BFA16c5e3c', 'Linda', 'Olsen', 'Dominguez, Mcmillan and Donovan', 'Bensonview'),
   ('053d585Ab6b3159', 'Joanna', 'Bender', 'Martin, Lang and Andrade', 'West Priscilla'),
   ('2d08FB17EE273F4', 'Aimee', 'Downs', 'Steele Group', 'Chavezborough');
   ```

11. **Verify Data**
   ```sql
   SELECT * FROM vsv.customers;
   ```

---

## ✅ Step 4: Grant Remote Access and Permissions
1. **Check Users**
   ```sql
   SELECT user, host FROM mysql.user WHERE user = 'root';
   ```
2. **Create Remote Root User**
   ```sql
   CREATE USER 'root'@'%' IDENTIFIED BY 'Yaswanth@123';
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
   FLUSH PRIVILEGES;
   ALTER USER 'root'@'%' IDENTIFIED BY 'Yaswanth@123';
   ```

---

## ✅ Step 5: Create MySQL Database for TARGET on AWS (RDS)
1. **Launch MySQL RDS Instance**
   - Engine: MySQL 8.4.3
   - Free tier template
   - Identifier: `my-sqlserver-db`
   - Username: `admin`, Password: `yaswanth123`
   - Instance class: `db.t3.micro`
   - Storage: 20 GiB
   - Public Access: No

2. **Get RDS Endpoint**
   - e.g., `my-sqlserver-dbc0n8k0a0swtz.us-east-1.rds.amazonaws.com`

3. **Connect with MySQL Workbench**
   - Host: RDS Endpoint
   - User: `admin`, Password: `yaswanth123`

4. **Create Database Schema on RDS**
   ```sql
   CREATE DATABASE vsv;
   USE vsv;
   SHOW TABLES;
   ```

---

## ✅ Setup AWS DMS

### 🔹 Step 1: Create Replication Instance
- Name: `ec2-rds`
- Class: `dms.t3.medium`
- Engine: 3.5.2
- Storage: 50 GiB
- VPC: Default, Subnet group: default, Publicly Accessible: Yes

### 🔹 Step 2: Create Endpoints
- **Source Endpoint**
  - Identifier: `source-from-ec2-db`
  - Type: Source, Engine: MySQL
  - Host: EC2 DNS
  - Port: 3306, User: root, Password: `yaswanth123`

- **Target Endpoint**
  - Identifier: `target-rds`
  - Type: Target, Engine: MySQL
  - Host: RDS Endpoint
  - Port: 3306, User: admin, Password: `yaswanth123`

### 🔹 Step 3: Create Migration Task
- Task identifier: `migration-form-ec2-db-to-rds`
- Replication instance: `ec2-rds`
- Source: `source-from-ec2-db`, Target: `target-rds`
- Migration Type: Migrate existing data and replicate ongoing changes
- Table Mapping: Schema: `vsv`, Table: `customers`
- Task startup: Automatically

---

## ✅ Final Verification
1. **Check Data on RDS**
   ```sql
   SELECT * FROM vsv.customers;
   ```
2. **Insert New Records on EC2 Source**
   ```sql
   INSERT INTO customers (customer_id, first_name, last_name, company, city)
   VALUES ('123132d08FB17EE273F4', 'vsv', 'veera', 'Steele Groupd', 'hyderabad');
   ```
3. **Check CDC Sync to RDS**
   - Verify new record appears in RDS.

✅ **Database Migration from EC2 to RDS using AWS DMS Complete!**

