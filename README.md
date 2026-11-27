# End-to-End Microservices Platform on AWS EKS

Production-style AWS platform built entirely as code: Terraform provisions the network and EKS cluster, Jenkins builds and scans a containerized Java app, and ArgoCD deploys it to EKS with Helm (GitOps). Prometheus and Grafana provide monitoring.

![Architecture](docs/architecture.png)

## Tech Stack
| Area | Tools |
|---|---|
| Cloud | AWS (VPC, EKS, ECR, IAM OIDC/IRSA, S3) |
| IaC | Terraform (modular) |
| CI | Jenkins, Maven, Docker (multi-stage), Trivy |
| CD | Helm, ArgoCD (GitOps) |
| Monitoring | Prometheus, Grafana |

## Architecture Flow
1. **Terraform** creates the VPC (public/private subnets, NAT Gateway), EKS cluster, node group, ECR repo, and IAM OIDC roles.
2. A developer pushes code, and **Jenkins** builds the Java app with Maven.
3. Jenkins builds a multi-stage **Docker** image and scans it with **Trivy**. HIGH/CRITICAL findings fail the build.
4. The image is pushed to **Amazon ECR**, and Jenkins updates the image tag in the Helm values.
5. **ArgoCD** detects the change in Git and syncs the **Helm** chart to EKS with rolling updates.
6. **Prometheus** scrapes cluster and pod metrics, and **Grafana** dashboards show CPU/memory, node health, and latency.

## Repository Structure
```
terraform/        # VPC, EKS, IAM/OIDC, ECR modules
app/              # Java application source
Dockerfile        # Multi-stage build
Jenkinsfile       # Build -> Trivy scan -> Push to ECR -> Update Helm tag
helm/             # Helm chart for the app
argocd/           # ArgoCD Application manifest
monitoring/       # Prometheus / Grafana setup
docs/             # Architecture diagram and screenshots
```

## How to Run
```bash
# 1. Provision infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# 2. Connect kubectl to the cluster
aws eks update-kubeconfig --region <region> --name <cluster-name>

# 3. Install ArgoCD and deploy the app
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/application.yaml
```

## Screenshots
| ArgoCD Synced | Grafana Dashboard | Trivy Scan |
|---|---|---|
| ![](docs/argocd.png) | ![](docs/grafana.png) | ![](docs/trivy.png) |

## Cleanup
```bash
cd terraform && terraform destroy
```

## Author
**Bonigi Syam Prasad**, DevOps & Cloud Engineer
[LinkedIn](https://linkedin.com/in/bonigi)
# aws-eks-microservices-platform
AWS EKS platform as code: Terraform, Jenkins + Trivy CI, Docker, Helm, ArgoCD GitOps, Prometheus/Grafana
