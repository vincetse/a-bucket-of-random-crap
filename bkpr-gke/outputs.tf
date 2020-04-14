output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://prometheus.${var.bkpr_dns_domain}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://grafana.${var.bkpr_dns_domain}"
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "https://kibana.${var.bkpr_dns_domain}"
}
