# 🚀 AWS Database Migration Service: Migrating Databases from EC2 to AWS RDS Using DMS (Manual Process)

<table style="width: 100%; margin-bottom: 20px;">
  <tr>
    <td align="center" style="padding: 10px; background-color: #f4f4f9; border-radius: 8px;">
      <img src="https://github.com/arumullayaswanth/ec2-to-rds-migrate/blob/a8a5dc2cea620f6553770394107925250458f0c5/Pictures_ec2-to-rds/ec2-to-rds-migrate-1.png" width="80%" style="border: 2px solid #ddd; border-radius: 10px;">
      <br><b>EC2 to RDS Migration Using AWS DMS - Architecture Diagram</b>
    </td>
  </tr>
</table>

<table style="width: 100%; margin-bottom: 20px;">
  <tr>
    <td align="center" style="padding: 10px; background-color: #e9f7f5; border-radius: 8px;">
      <img src="https://github.com/arumullayaswanth/ec2-to-rds-migrate/blob/16167711c188c73ed1a906fe0d4d8b00363f918f/Pictures_ec2-to-rds/ec2-to-rds-migrate-2.png" width="120%" style="border: 2px solid #ddd; border-radius: 10px;">
      <br><b>EC2 to RDS Database Migration - DMS Manual Workflow</b>
    </td>
  </tr>
</table>

<table style="width: 100%; margin-bottom: 20px;">
  <tr>
    <td align="center" style="padding: 10px; background-color: #e9f7f5; border-radius: 8px;">
      <img src="https://github.com/arumullayaswanth/ec2-to-rds-migrate/blob/a8a5dc2cea620f6553770394107925250458f0c5/Pictures_ec2-to-rds/AWS%20Database%20Migration%20Services.png" width="120%" style="border: 2px solid #ddd; border-radius: 10px;">
      <br><b>Database Migration Overview: EC2 → RDS via DMS</b>
    </td>
  </tr>
</table>

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

1.	Go to the Instances page in the EC2 dashboard
2.	Select the database-source-ec2 instance
3.	Click Connect → Choose EC2 Instance Connect (Browser-based SSH) or your preferred method (e.g., SSH with .pem key)
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

8. **Login to MySQL Using the Temporary Password**
   ```bash
   sudo mysql -u root -p
   ```
   🔐 Enter the temporary password from Step 7

9. **Change the Root Password**
   ```bash
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'Admin@123';
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
INSERT INTO user (customer_id, first_name, last_name, company, city) VALUES
('CUST1001', 'John', 'Doe', 'TechCorp', 'New York'),
('CUST1002', 'Jane', 'Smith', 'InnovateX', 'San Francisco'),
('CUST1003', 'Aidan', 'Brown', 'GlobalTech', 'Los Angeles');

```

---

17. **Query the Table**

```sql
SELECT * FROM vsv.user;
```

---



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


# ✅ Step 5: Create MySQL Database for TARGET on AWS (RDS)

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

## 🔹 4. Get Your RDS Endpoint
1. Go back to **RDS → Databases**.  
2. Click on your DB instance: `my-sqlserver-db`.  
3. Scroll down to **Connectivity & Security**.  
4. Copy the **Endpoint**.

👉 Example:  
`my-sqlserver-dbc0n8k0a0swtz.us-east-1.rds.amazonaws.com`


## 🔄 Verification Steps
---
**Connect to RDS via MySQL Workbench**
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


---
---
#  🚀 SETUP RDS Migration  MIGRATION SERVICE

### ✅ Step 1: Create Replication Instance & IAM Role

#### 🔸 1.1 Go to DMS:
- In AWS Console, search for **Database Migration Service** and open it.  
- On the left menu, click **Replication instances**.  
- Click **Create replication instance**.

#### 🔸 1.2 Create IAM Role (if not created already):
- Open a new tab → Go to **IAM → Roles → Click Create Role**

**IAM Role Configuration:**
1. **Trusted entity type:** AWS Service  
2. **Use case:** Select DMS  
3. **Permissions:** Administrator Access  
4. **Role Name:** `dms-cloudwatch-log-role`  
5. Click **Create Role**

#### 🔸 1.3 Replication Instance Configuration:
- **Name:** ec2-rds  
- **Instance class:** `dms.t3.medium`  
- **Engine version:** 3.5.2  
- **High Availability:** Dev or test workload (Single-AZ)  
- **Storage:** 50 GiB  
- **Network Type:** IPv4  
- **VPC:** Default VPC  
- **Replication Subnet Group:** default  
- **Publicly Accessible:** ✅ Yes  

Click **Create replication instance**

---

## ✅ Step 2: Create Endpoints (Source Endpoint) (source endpoint we have to give the ec2 instance information)

    #### 🔸 2.1 Go to DMS → Endpoints → Click Create Endpoint

            #### 🔹 SOURCE Endpoint (EC2 MySQL Database)

#### 🔸 2.2 Create IAM Role for Endpoint (if prompted):
- **Go to IAM → Create Role**  
- **Trusted entity:** AWS Service  
- **Use case:** DMS  
- **Permissions:** AdministratorAccess  
- **Role Name:** `dms-cloudwatch-log-role`  
- Click **Create Role**

#### 🔸 2.3 Configure Endpoint (Source Endpoint):
- **Endpoint type:** Source  
- **Endpoint identifier:** `source-from-ec2-db`  //any name
- **Source engine:** MySQL  
- **Access method:** Provide access information manually 
  **Fill in:**
   **Copy EC2 DNS:**
  - Go to your EC2 instance (source Ec2-rds instance ) open --> Copy Public IPv4 DNS
  - **Server name:** Paste source Ec2-rds instance Public IPv4 DNS (eg: ec2-18-234-236-228.compute-1.amazonaws.com)
  -  **Port:** 3306
  -  **Username:** root
  -  **Password:** `Admin@123`  

##### 🔸 2.4 Test Connection:
- Scroll down and click **Run Test**  
- ✅ If successful, EC2 database is connected properly  
- Click **Create endpoint**

---

## ✅ Step 3: Create Target Endpoint (RDS MySQL) (target endpoint we have to give the Rds information)

### 🔹 3.1 Open AWS DMS → Endpoints → Click Create Endpoint

### 🔹 3.2 Configure the Target Endpoint
- **Endpoint type:** Target Endpoint
- **✅Select RDS DB instance**
- **Select RDS DB instance:** Select `my-sqlserver-db`  
- **Endpoint identifier:** `target-rds`  // give any name
- **Target engine:** MySQL  

### 🔹 3.3 Access Configuration
- **Access method:** Provide access information manually  
- **Server name:** (auto-filled RDS Endpoint)  
- **Port:** 3306  
- **Username:** admin  
- **Password:** `Yaswanth123reddy`  

### 🔹 3.4 Test the Connection
- **Select Replication Instance:** `ec2-rds`  
- Click **Run test**  
- ✅ If successful, click **Create endpoint**

📝 Note: At this point, you should have two endpoints:
- `source-form-ec2-db` (from EC2)  
- `target-rds` (to RDS)

---

## ✅ Step 4: Create Database Migration Task

### 🔹 4.1 Open DMS → Database migration tasks → Click Create database migration task

### 🔹 4.2 Configure Migration Task
- **Task identifier:** `migration-form-ec2-db-to-rds`  
- **Replication instance:** `ec2-rds`  
- **Source database endpoint:** `source-form-ec2-db`  
- **Target database endpoint:** `target-rds`  

### 🔹 4.3 Migration Type
- **Migration type:** Migrate existing data and replicate ongoing changes  
- **How long to replicate:** Indefinitely  

### 🔹 4.4 Task Settings
- **Editing mode:** Wizard  
- **Custom CDC stop mode:** Disable  
- **Target table preparation mode:** Do nothing  
- **Stop task after full load completes:** Don't stop  
- **LOB columns:** Don't include  
- **Data validation:** Turn off  

### 🔹 4.5 Table Mappings
- Click on **Selection rules** → Add new selection rule:  
  - **Schema:** `vsv`  [(vsv is my datadase name) or give % it wii take all datadase]
  - **Table name:** `customers`  (enteryour table name here [i am create customers table vsv database] or give % it wii take all table)
  - **Action:** Include  

### 🔹 4.6 Final Configuration
- **Pre-migration assessment:** ❌ Deselect it  
- **Task startup configuration:** Automatically on create  

Click **Create database migration task**

---

## ✅ Step 4 Complete!
Once the task runs, DMS will:
- Load existing records from EC2 MySQL (`vsv.customers`) to RDS  
- Start capturing ongoing changes (CDC)

---

## 🔄 Verification Steps
---
## ✅ Step 5: Connect to RDS via MySQL Workbench
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

## ✅ Step 6: Create and Verify Database
```sql
CREATE DATABASE vsv;
USE vsv;
SHOW TABLES;
```
Click ⚡ to execute and verify your tables and data.

## ✅ Step 7 : Step-by-Step: Insert Data into EC2 MySQL & Verify in RDS

## 1. Insert Sample Data

### `customers` Table

```sql
INSERT INTO customers (customer_id, first_name, last_name, company, city) VALUES
('CUST001', 'John', 'Doe', 'Acme Corp', 'New York'),
('CUST002', 'Jane', 'Smith', 'Global Tech', 'San Francisco');
```

### `user` Table

```sql
INSERT INTO `user` (customer_id, first_name, last_name, company, city) VALUES
('USR001', 'Alice', 'Brown', 'TechSphere', 'Austin'),
('USR002', 'Brian', 'Taylor', 'DevSolutions', 'Denver');
```

---

## 2. Verify Data

```sql
SELECT * FROM customers;
SELECT * FROM `user`;
```

---

## ✅ Step 8: Create and Verify Database MySQL Workbench
```sql
CREATE DATABASE vsv;
USE vsv;
SHOW TABLES;
```
Click ⚡ to execute and verify your tables and data.






