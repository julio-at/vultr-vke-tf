/* -----------------------------------------------------------------------------
   VPC (Vultr)
   - Si dejas vpc_v4_subnet = "", Vultr genera automáticamente el bloque.
   - Si defines vpc_v4_subnet y vpc_v4_subnet_mask, se usan esos valores.
----------------------------------------------------------------------------- */

# Caso A: VPC automática (sin definir CIDR)
resource "vultr_vpc" "vpc_auto" {
  count       = var.vpc_v4_subnet == "" ? 1 : 0
  description = var.vpc_description
  region      = var.region
}

# Caso B: VPC con CIDR definido por el usuario
resource "vultr_vpc" "vpc_custom" {
  count          = var.vpc_v4_subnet != "" ? 1 : 0
  description    = var.vpc_description
  region         = var.region
  v4_subnet      = var.vpc_v4_subnet
  v4_subnet_mask = var.vpc_v4_subnet_mask
}

locals {
  vpc_id = var.vpc_v4_subnet == "" ? vultr_vpc.vpc_auto[0].id : vultr_vpc.vpc_custom[0].id
}

/* -----------------------------------------------------------------------------
   Kubernetes Cluster (VKE)
   - Requiere un node_pools inicial (luego puedes gestionarlo por separado).
   - Soporta vpc_id, ha_controlplanes, enable_firewall, etc.
----------------------------------------------------------------------------- */
resource "vultr_kubernetes" "vke" {
  region  = var.region
  label   = var.cluster_name
  version = var.kubernetes_version

  vpc_id           = local.vpc_id
  ha_controlplanes = var.ha_controlplanes
  enable_firewall  = var.enable_firewall_managed

  node_pools {
    node_quantity = var.node_quantity
    plan          = var.node_plan
    label         = "${var.cluster_name}-np"

    auto_scaler = var.enable_autoscaler
    min_nodes   = var.enable_autoscaler ? var.min_nodes : null
    max_nodes   = var.enable_autoscaler ? var.max_nodes : null

    labels = var.node_labels
  }
}

