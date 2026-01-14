# DevSecOps Capstone Project on GKE

![Java](https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-GKE-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Build](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge)

A comprehensive **End-to-End DevSecOps pipeline** deployed on Google Kubernetes Engine (GKE), demonstrating **Shift Left** security principles throughout the software development lifecycle.

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD Pipeline Flow                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   Developer Push                                                                │
│        │                                                                        │
│        ▼                                                                        │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐      │
│   │  Code   │───▶│  Unit   │───▶│  SAST   │───▶│  Build  │───▶│ Image   │      │
│   │ Checkout│    │  Tests  │    │ (Snyk)  │    │ Docker  │    │  Scan   │      │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘    │ (Trivy) │      │
│                                                               └────┬────┘      │
│                                                                    │            │
│                                                                    ▼            │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐              ┌─────────────┐       │
│   │  DAST   │◀───│   App   │◀───│ ArgoCD  │◀─────────────│ Docker Hub  │       │
│   │  (ZAP)  │    │ Running │    │  Sync   │              │    Push     │       │
│   └─────────┘    └─────────┘    └─────────┘              └─────────────┘       │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Pipeline Stages:**

1. **Code Commit** → GitHub triggers the CI pipeline
2. **Unit Testing** → Maven/JUnit validates application logic
3. **SAST Scanning** → Snyk analyzes dependencies for vulnerabilities
4. **Container Build** → Multi-stage Docker build with Alpine base
5. **Image Scanning** → Trivy scans for container vulnerabilities
6. **Registry Push** → Image pushed to Docker Hub
7. **GitOps Sync** → ArgoCD deploys to GKE cluster
8. **DAST Scanning** → OWASP ZAP performs runtime security testing

---

## 📁 Project Structure

```
gke-devsecops-project/
├── app-code/                    # Java Spring Boot application
│   ├── src/                     # Application source code
│   ├── pom.xml                  # Maven dependencies
│   └── Dockerfile               # Multi-stage build definition
├── terraform/                   # Infrastructure as Code
│   ├── providers.tf             # GCP provider configuration
│   ├── variables.tf             # Input variables
│   ├── vpc.tf                   # VPC & Subnet definitions
│   └── gke.tf                   # GKE cluster & node pool
├── k8s-manifests/               # Kubernetes manifests (ArgoCD source)
│   ├── deployment.yaml          # Application deployment
│   └── service.yaml             # LoadBalancer service
├── .github/workflows/           # CI/CD pipeline
│   └── ci-pipeline.yml          # GitHub Actions workflow
└── reports/                     # Security scan reports
```

---

## ✅ Prerequisites

Ensure the following tools are installed and configured on your machine:

| Tool           | Version | Purpose                                |
| -------------- | ------- | -------------------------------------- |
| **Terraform**  | >= 1.0  | Infrastructure provisioning            |
| **kubectl**    | >= 1.25 | Kubernetes cluster management          |
| **gcloud CLI** | Latest  | GCP authentication & configuration     |
| **Docker**     | >= 20.0 | Local container builds (optional)      |
| **Helm**       | >= 3.0  | Installing ArgoCD, Prometheus, Grafana |

**GCP Requirements:**

- Active GCP project with billing enabled
- APIs enabled: Compute Engine, Kubernetes Engine, Container Registry
- Service account with appropriate IAM roles

---

## 🚀 Step-by-Step Deployment Guide

### 1. Infrastructure Provisioning (Terraform)

```bash
# Navigate to the Terraform directory
cd terraform/

# Initialize Terraform
terraform init

# Preview the infrastructure changes
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

**Resources Created:**

- Custom VPC and Subnet
- Zonal GKE Cluster (optimized for GCP quotas)
- Custom Node Pool with 2x `e2-medium` instances

### 2. Configure kubectl Access

```bash
# Authenticate with GKE cluster
gcloud container clusters get-credentials <CLUSTER_NAME> \
    --zone <ZONE> \
    --project <PROJECT_ID>

# Verify cluster access
kubectl get nodes
```

### 3. CI Pipeline Execution

The pipeline triggers automatically on push to `main` branch when changes are made to:

- `app-code/**`
- `.github/workflows/**`

**Required GitHub Secrets:**
| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |
| `SNYK_TOKEN` | Snyk API token for SAST |

### 4. ArgoCD Setup & Access

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Expose ArgoCD Server (option 1: LoadBalancer)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get ArgoCD external IP
kubectl get svc argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d && echo
```

**Login:** Navigate to the external IP, use `admin` and the retrieved password.

### 5. Monitoring Stack (Prometheus & Grafana)

```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace

# Access Grafana (port-forward)
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

**Grafana Credentials:**

- **Username:** `admin`
- **Password:** `prom-operator`

---

## 🔐 Security Measures

This project implements security at every stage of the pipeline:

| Stage              | Tool                                                                                             | Purpose                           |
| ------------------ | ------------------------------------------------------------------------------------------------ | --------------------------------- |
| **SAST**           | ![Snyk](https://img.shields.io/badge/Snyk-4C4A73?style=flat&logo=snyk&logoColor=white)           | Dependency vulnerability scanning |
| **Container Scan** | ![Trivy](https://img.shields.io/badge/Trivy-1904DA?style=flat&logo=aquasecurity&logoColor=white) | Image vulnerability detection     |
| **DAST**           | ![OWASP](https://img.shields.io/badge/OWASP_ZAP-000000?style=flat&logo=owasp&logoColor=white)    | Runtime security testing          |
| **Container**      | Non-root user                                                                                    | Reduced attack surface            |
| **Image**          | Alpine-based                                                                                     | Minimal footprint, fewer CVEs     |

### Security Best Practices Implemented:

- ✅ Multi-stage Docker builds for minimal image size
- ✅ Non-root user execution in containers
- ✅ Health checks (liveness & readiness probes)
- ✅ Resource limits to prevent DoS
- ✅ Shift-left security with pre-deployment scanning
- ✅ Post-deployment DAST validation

---

## 📸 Screenshots

### CI Pipeline Success

![CI Pipeline](screenshots/ci-pipeline-success.png)

---

### ArgoCD Application Sync


![ArgoCD Sync](screenshots/argocd-sync.png)

---

### Grafana Dashboard


![Grafana Dashboard](screenshots/grafana-dashboard.png)

---

### OWASP ZAP Security Report


![ZAP Report](screenshots/zap-report.png)

---

## 🧹 Cleanup

To destroy all infrastructure and avoid ongoing charges:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s-manifests/

# Destroy Terraform infrastructure
cd terraform/
terraform destroy -auto-approve
```

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

**DevOps Engineer** - Capstone Project Demonstration

---

> **Note:** Remember to replace placeholder values (e.g., `<CLUSTER_NAME>`, `<ZONE>`, `<PROJECT_ID>`) with your actual configuration values.
