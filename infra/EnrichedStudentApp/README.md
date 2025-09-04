Steps to run Enriched Student App on ec2 instances: 

1. Provision two ec2 instances (ubuntu) 
2. Change the names (optional): 
sudo hotsnamectl hostname app 
sudo hotsnamectl hostname db 

SG settings : For app server open : 8080, 22 For db server open 22 and 3360 

3. On db server: 

sudo apt update 
sudo apt install mysql-server  -y
sudo systemctl status mysql.service 
sudo systemctl enable mysql.service
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf  [change bind-server to 0.0.0.0]
sudo systemctl stop mysql.service 
sudo systemctl start mysql.service 
systemctl status mysql.service 

sudo MySQL 
CREATE DATABASE eStudentdb ; 
CREATE USER 'springuser' IDENTIFIED BY 'strongpassword';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE ON eStudentdb.* TO 'springuser';

4. On app server 

sudo  apt update
git version
sudo apt install openjdk-17-jdk maven -y
git clone https://github.com/tiwaprat/EnrichedStudentApp.git
vi application.properties   update the hostname of database
From Enriched dir run  mvn clean package -U and java -jar target/student-app-1.0.0.jar
 





