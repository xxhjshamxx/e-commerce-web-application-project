# Automated E-Commerce Deployment Platform - Project 4

## Project Engineering Team
- **Ramzy Ahmed Ramzy** - Lead Architect
- **Hesham Abdelnasser Mohamed**
- **Ibrahim Alaa Abo Elnasr**
- **Ahmed Gamal Abdelazeem**
- **Islam Gamal Mahmoud Abdelgawad**

---

## Project Description
This **Automated E-Commerce Deployment Platform** is a production-grade, cloud-native microservices application built with modern DevOps practices and tools. The project demonstrates a complete, end-to-end CI/CD pipeline, infrastructure as code, automated scaling, monitoring, and disaster recovery, making it an exemplary implementation of enterprise-grade DevOps workflows.

Key architecture highlights:
- **Cloud-Native**: Designed for Kubernetes with auto-scaling capabilities
- **Multi-Cloud Ready**: Infrastructure as code supports deployment to major cloud providers
- **Microservices-Oriented**: 11+ independent services communicating via gRPC
- **DevOps-First**: Automated provisioning, deployment, monitoring, and rollbacks

---

## Tech Stack & Tools
| Category               | Technologies Used                                                                 |
|------------------------|-----------------------------------------------------------------------------------|
| **Application Runtime**| Go, Python, Java, Node.js, .NET Core                                              |
| **Containerization**   | Docker                                                                             |
| **Orchestration**      | Kubernetes (Amazon EKS), Horizontal Pod Autoscaler (HPA)                           |
| **CI/CD**              | Jenkins                                                                           |
| **Infrastructure as Code** | Terraform                                                                       |
| **Configuration Management** | Ansible                                                                       |
| **Ingress/Proxy**      | NGINX Ingress Controller                                                          |
| **Cloud Provider**     | AWS (EC2, EKS, S3, IAM, Route53)                                                  |
| **Monitoring**         | Prometheus + Grafana (via Helm)                                                   |

---

## Architecture Overview
Traffic flows through the following layers:
1. **Internet → NGINX Ingress Controller**: Routes external HTTP traffic to the frontend service
2. **Frontend Service (Go)**: Serves UI, handles user sessions, and communicates with backend services over gRPC
3. **Backend Microservices**: 10+ independent services (cart, currency, checkout, payment, etc.)
4. **Data/Storage**: Redis for cart persistence, in-memory product catalog, etc.

All components are containerized and orchestrated by EKS for high availability and resilience.

---

## Features & Compliance (Project 4 Deliverables)
Here is how each university Project 4 requirement is fully implemented:

| # | Deliverable | Implementation Details |
|---|-------------|------------------------|
| **1** | Dockerized Microservices | Each service (11 total) has its own `Dockerfile` in `src/[service]/` |
| **2** | CI/CD Pipelines (Jenkins) | Jenkins pipeline files for all services in `jenkinsfiles/` directory |
| **3** | Kubernetes Deployment with HPA | Kubernetes manifests in `kubernetes-files/`, plus `hpa-frontend.yaml` auto-scales frontend 2→5 replicas at 70% CPU |
| **4** | Ansible Scripts | `ansible/deploy-k8s.yml` automates full Kubernetes manifest deployment |
| **5** | Prometheus/Grafana Monitoring | Installation script included in Terraform EC2 init (install-tools.sh) |
| **6** | NGINX Reverse Proxy | `ingress-nginx.yaml` Ingress resource routes traffic to frontend |
| **7** | Terraform (AWS EC2, RDS, S3, ELB, EKS) | `terraform_main_ec2/`, `eks-terraform/`, `s3-buckets/`, `ecr-terraform/` |
| **8** | Automated Rollbacks | Jenkinsfiles include `post { failure { ... } }` that runs `kubectl rollout undo` on deployment failure |
| **9** | Git Repository Setup | Full git configuration, commits, and repo management integrated into pipeline |

---

## Deployment Instructions

### Prerequisites
- AWS CLI configured with valid credentials
- `terraform` installed
- `ansible` installed
- `kubectl` installed

---

### Step 1: Provision Infrastructure with Terraform
First, deploy core EC2 jumphost and VPC:
```bash
cd terraform_main_ec2
terraform init
terraform plan
terraform apply
```

Then deploy EKS cluster:
```bash
cd ../eks-terraform
terraform init
terraform plan
terraform apply
```

---

### Step 2: Deploy Kubernetes Manifests with Ansible
Once the infrastructure is ready and you have access to the EKS cluster:
```bash
cd ../ansible
# Create inventory file (or use dynamic inventory)
ansible-playbook -i inventory.ini deploy-k8s.yml
```

---

### Step 3: Verify Deployment
Check all resources are running:
```bash
kubectl get all
kubectl get ingress
kubectl get hpa
```

---

## Contributors
Special thanks to the Project Engineering Team for their hard work on this enterprise-grade platform!
