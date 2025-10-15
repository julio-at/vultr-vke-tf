output "cluster_id" {
  description = "ID del clúster VKE."
  value       = vultr_kubernetes.vke.id
}

output "region" {
  description = "Región efectiva."
  value       = vultr_kubernetes.vke.region
}

output "api_endpoint" {
  description = "Endpoint (FQDN) del control plane."
  value       = vultr_kubernetes.vke.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig en texto claro (decodificado)."
  value       = base64decode(vultr_kubernetes.vke.kube_config)
  sensitive   = true
}

