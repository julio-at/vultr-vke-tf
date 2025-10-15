# Vultr Kubernetes (VKE) with Terraform — Clone & Run

This project provisions a **Vultr VPC** and a **VKE cluster** using **Terraform only**. No external scripts, and the `.tf` files are written for clarity (no one-liners).

> TL;DR: **Export `VULTR_API_KEY` → edit `terraform.tfvars` → `terraform init/plan/apply` → kubeconfig → `kubectl get nodes`.**

---

## 1) Project layout

```
vultr-vke-tf/
├─ versions.tf
├─ providers.tf
├─ variables.tf
├─ main.tf
├─ outputs.tf
└─ terraform.tfvars.example
```

- `versions.tf`: minimal Terraform & provider versions.  
- `providers.tf`: Vultr provider (reads `VULTR_API_KEY` from env).  
- `variables.tf`: clear inputs (region, version, plan, counts, VPC, flags).  
- `main.tf`: VPC (auto or custom) + VKE cluster (with initial node pool).  
- `outputs.tf`: kubeconfig (decoded), IDs & metadata.  
- `terraform.tfvars.example`: copy/adjust example.

---

## 2) Prerequisites

- **Vultr account** with billing enabled.  
- **API Key** with read/write permissions.  
- **Tools**:
  - Terraform ≥ 1.6.0
  - kubectl (optional, for validation)

Authenticate (one-liner):
```bash
export VULTR_API_KEY="<your_vultr_api_key>"
```

---

## 3) Where each slug goes

| What | Examples | Variable |
|---|---|---|
| **Region** | `ewr`, `sjc`, `ams`, `fra`, `sgp`, … | `region = "ewr"` |
| **Exact K8s version (VKE)** | `v1.28.2+1` (example) | `kubernetes_version = "v1.28.2+1"` |
| **Node plan / size** | `vc2-2c-4gb`, `vc2-4c-8gb` *(depends on current offerings)* | `node_plan = "vc2-2c-4gb"` |

> Tip: You can see region/plan/version slugs in the **Vultr control panel**. `vultr-cli` or the API can also list them, but it’s not required for this flow.

---

## 4) Configure your variables

Copy the example and adjust:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Example (production-friendly with exact pin; adjust as needed):
```hcl
region        = "ewr"
cluster_name  = "vke-demo"

# Exact K8s version (use one available in your region)
kubernetes_version = "v1.28.2+1"

# Node plan/size
node_plan     = "vc2-2c-4gb"
node_quantity = 3

# Default pool autoscaler
enable_autoscaler = false
min_nodes         = 2
max_nodes         = 6

# Control plane HA and VKE-managed firewall (optional)
ha_controlplanes        = false
enable_firewall_managed = false

# VPC: leave vpc_v4_subnet = "" to let Vultr auto-assign a subnet
vpc_description    = "vpc for vke"
vpc_v4_subnet      = ""     # e.g., "10.20.0.0" if you want to define it
vpc_v4_subnet_mask = 16     # used only when vpc_v4_subnet != ""

# Optional node labels (K8s labels)
node_labels = {
  role = "system"
}
```

**Notes**
- If you **leave `vpc_v4_subnet = ""`**, Terraform will create a VPC and **Vultr will assign** the subnet automatically.  
- If you **set `vpc_v4_subnet`** (e.g., `10.20.0.0`) and `vpc_v4_subnet_mask`, the VPC will use that CIDR.

---

## 5) Initialize, validate, plan, and apply

```bash
terraform init -upgrade
terraform fmt
terraform validate
terraform plan -out tfplan
terraform apply -auto-approve tfplan
```

What gets created:
- **VPC** (auto or with your CIDR).
- **VKE cluster** with a **system node pool**.

---

## 6) kubeconfig & verification

```bash
terraform output -raw kubeconfig > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

kubectl cluster-info
kubectl get nodes -o wide
```

> The `kubeconfig` is **sensitive**: don’t publish or commit it.

Useful sanity checks:
```bash
kubectl -n kube-system get pods
kubectl get storageclass
kubectl get svc -A
```

---

## 7) Troubleshooting (quick)

- **`Unsupported block type "v4"` in VPC**  
  The `vultr_vpc` resource **does not** use `v4 {}` blocks—only the flat attributes `v4_subnet` and `v4_subnet_mask`. This repo uses two resources with `count` and a `local.vpc_id`.

- **Ternary error in `locals`**  
  Keep it **on one line**:  
  `vpc_id = var.vpc_v4_subnet == "" ? vultr_vpc.vpc_auto[0].id : vultr_vpc.vpc_custom[0].id`

- **Unavailable plan/version**  
  Switch `node_plan` or `kubernetes_version` to one available in your region.

- **Account limits**  
  If capacity errors occur, reduce `node_quantity`, change plan/region, or adjust limits in your account.

---

## 8) Next steps (optional)

- Add a separate **workloads node pool** with taints/labels (keep “sysnp” for critical add-ons).  
- **Ingress** (Nginx/Traefik) with **one Load Balancer** to save cost.  
- Pool autoscaling + HPA/VPA for workloads.  
- Observability: metrics + logs.  
- Backups and upgrade policies for serious environments.

---

## 9) Clean up

```bash
terraform destroy -auto-approve
```

This removes the cluster and the VPC created by this project.
