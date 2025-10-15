variable "region" {
  description = "Región de Vultr (slug, ej. ewr, sjc, ams, fra, sgp...)."
  type        = string
}

variable "cluster_name" {
  description = "Etiqueta/Nombre del clúster VKE."
  type        = string
  default     = "vke-demo"
}

variable "kubernetes_version" {
  description = "Versión EXACTA de VKE (slug tipo v1.28.2+1)."
  type        = string
}

variable "node_plan" {
  description = "Plan/tamaño de nodo (slug de Droplet, ej. vc2-2c-4gb)."
  type        = string
}

variable "node_quantity" {
  description = "Cantidad de nodos en el pool por defecto."
  type        = number
  default     = 3
}

variable "enable_autoscaler" {
  description = "Habilitar autoscaler en el node pool por defecto."
  type        = bool
  default     = false
}

variable "min_nodes" {
  description = "Mínimo de nodos para autoscaler (si está habilitado)."
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Máximo de nodos para autoscaler (si está habilitado)."
  type        = number
  default     = 6
}

variable "enable_firewall_managed" {
  description = "Crear clúster con firewall gestionado por VKE."
  type        = bool
  default     = false
}

variable "ha_controlplanes" {
  description = "Control planes HA (multi-control plane)."
  type        = bool
  default     = false
}

/* VPC (Vultr) — define el bloque y máscara IPv4 si no quieres que Vultr los genere automáticamente */
variable "vpc_description" {
  description = "Descripción de la VPC."
  type        = string
  default     = "vpc for vke"
}

variable "vpc_v4_subnet" {
  description = "Subred IPv4 base (ej. 10.20.0.0). Déjalo vacío para que Vultr asigne."
  type        = string
  default     = ""
}

variable "vpc_v4_subnet_mask" {
  description = "Máscara (bits) para la subred IPv4 (ej. 16, 24). Se usa solo si vpc_v4_subnet != \"\"."
  type        = number
  default     = 16
}

/* Etiquetas/labels opcionales a nivel de node pool (key=value en K8s). */
variable "node_labels" {
  description = "Mapa de labels para los nodos del pool por defecto."
  type        = map(string)
  default     = {}
}

