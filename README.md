# Secured Multi-AZ ECS Fargate Deployment on AWS

This project demonstrates a secure, highly available containerized application deployment on AWS using ECS Fargate across multiple Availability Zones. Built as a personal portfolio project showcasing industry best practices for cloud infrastructure including IaC with Terraform, centralized logging and monitoring, and a zero-trust security model. The architecture is optimized for personal cost management while maintaining production-grade security and reliability standards.

> [!IMPORTANT]
> This repository contains only the infrastructure layer for hosting the forked [journal-starter](https://github.com/z-fahmi-z/journal-starter) capstone project. All application logic and service code reside in this separate repository, ensuring a clean SoC between infrastructure and application development.

## Architecture Overview

The infrastructure spans two Availability Zones (A and B) within a single AWS VPC, featuring:

- **Public subnets** hosting the Application Load Balancer (ALB) for traffic distribution.
- **Private subnets** containing ECS Fargate tasks running containerized applications.
- **Multi-AZ RDS deployment** with automated failover capabilities.
- **Serverless compute** using AWS Fargate for container orchestration.
- **Centralized networking** through VPC Endpoints for private AWS service access.

![Architecture Overview](assets/secured-multiaz-ecs-dev-deployment.png)

## Infrastructure Features

- **S3 State Locking**: Terraform state management for concurrent operations safety.
- **Multi-AZ Deployment**: High compute and database availability through distribution across two Availability Zones.
- **AWS Bedrock Integration**: AI/ML capabilities integrated into the application stack.
- **CloudWatch & CloudTrail**: Comprehensive logging, monitoring, and audit trail for all activities.
- **RDS + Lambda Initialization**: Automated database schema setup via Lambda functions on deployment.

## Security Considerations

- **AWS Certificate Manager (ACM)**: SSL/TLS certificate management for secure HTTPS communications.
- **AWS Secrets Manager (ASM)**: Secure storage and rotation of sensitive credentials.
- **IAM Groups (Dev & Ops)**: Least-privilege access control with separate groups for dev and ops teams.
- **Task IAM Roles**: Fine-grained permissions for ECS tasks to access required AWS services.
- **GitHub IAM Roles (OIDC)**: Secure GitHub Actions integration using OpenID Connect.

## Trade-Offs (Optimized for Personal Cost)

- **VPC Endpoints instead of NAT Gateways**: Reduces cost significantly (NAT Gateway at ~$32/month vs VPC Endpoints at ~$7/month).
- **AWS Systems Manager Session Manager instead of EC2 Bastion**: Eliminates EC2 compute costs (~$15-30/month) and public exposure.

## ToDos: Setup & Dashboards (WIP)

> [!NOTE]
> This project is actively maintained as a demonstration of modern AWS infrastructure patterns. Feel free to explore the code and adapt it for your own learning purposes.