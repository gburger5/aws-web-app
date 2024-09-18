# Highly Available and Scalable Web Application

## Project Description

This project demonstrates a PoC of a highly available and scalable web application architecture deployed on AWS. The application uses Amazon EC2 instances behind an Elastic Load Balancer (ELB) to handle incoming traffic, along with Amazon RDS for relational database management. The architecture is designed to provide fault tolerance and scalability while utilizing Infrastructure as Code (IaC) with Terraform.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Setup](#setup)
- [Technologies Used](#technologies-used)

## Features

- **Load Balanced EC2 Instances**: Two EC2 instances behind an Elastic Load Balancer to distribute incoming traffic.
- **Amazon RDS**: MySQL database hosted on Amazon RDS, accessible from the EC2 instances.
- **Infrastructure as Code**: All resources provisioned using Terraform for easy management and reproducibility.
- **Auto-scaling**: Implement auto-scaling for EC2 instances based on demand.

## Architecture

The architecture consists of:
- **VPC**: A Virtual Private Cloud with public and private subnets in a Multi-AZ Deployment.
- **Auto Scaling Group**: Creates EC2 Instances in the public subnets based on demand. 
- **Elastic Load Balancer**: Distributes traffic among EC2 instances.
- **EC2 Instances**: Run the web application.
- **Amazon RDS**: Manages the MySQL database.

![Architecture Diagram](https://github.com/user-attachments/assets/14544ff0-6d4c-49e3-930e-135995412660)

## Setup

1. **Coming Soon**: Creating Bash/Batch Scripts for Ease of Use.

## Technologies Used

- **Terraform**: For provisioning infrastructure.
- **Amazon EC2**: Web instances.
- **AWS ELB**: Application Load Balancer.
- **Amazon RDS**: MySQL database.
- **AWS Auto-Scaling Group**: For horizontally scaling web instances to meet demand.
