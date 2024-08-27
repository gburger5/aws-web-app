# Project: Highly Available and Scalable Web Application
## Version 1.1 - EC2 Setup / File Organization / Security Group Setup
### Overview of Changes
![Topology1.1]([AWS-Web-App.pdf](https://github.com/user-attachments/files/16755779/AWS-Web-App.pdf)

### EC2 Instances and Security Group
- **EC2 Instances:**
  - Host web servers in the public subnets.
  - Provisioned with an appropriate AMI and instance type.

- **Security Group:**
  - Name: `ec2_security`
  - Description: Allow SSH, HTTP, and HTTPS inbound traffic.
  - Ingress Rules:
    - SSH (port 22) from `0.0.0.0/0`
    - HTTP (port 80) from `0.0.0.0/0`
    - HTTPS (port 443) from `0.0.0.0/0`
  - Egress Rule:
    - Allow all outbound traffic.

## Version 1.0 - VPC Setup
![Topology](https://github.com/user-attachments/assets/9c1fc67f-8d39-4dd3-8e02-d115002a0d15)
### Overview
This project sets up a Virtual Private Cloud (VPC) in AWS for a highly available and scalable web application. It includes public and private subnets, internet access, and routing components.

### VPC Configuration
- **VPC CIDR Block:** `10.0.0.0/16`
- **Region:** `us-east-1`

### Subnets
- **Public Subnets:**
  - CIDR: `10.0.1.0/24`, `10.0.2.0/24`
  - Purpose: Host resources that require direct internet access (e.g., web servers).

- **Private Subnets:**
  - CIDR: `10.0.3.0/24`, `10.0.4.0/24`
  - Purpose: Host resources that do not need direct internet access (e.g., databases).

### Routing
- **Internet Gateway:** 
  - Allows outbound traffic from public subnets to the internet.
  
- **NAT Gateway:**
  - Provides internet access to resources in private subnets while keeping them secure.

- **Route Tables:**
  - Public route table routes traffic from public subnets to the Internet Gateway.
  - Private route tables route traffic from private subnets to the NAT Gateway.

### Conclusion
This VPC setup serves as the foundation for deploying a scalable web application, ensuring both accessibility and security for the resources within.
