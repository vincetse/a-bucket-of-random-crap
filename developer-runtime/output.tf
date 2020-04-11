output "hephy_workflow_router" {
  value = data.kubernetes_service.hephy_workflow_router.load_balancer_ingress
  description = "Hephy Workflow router"
}

output "kong_proxy" {
  value = data.kubernetes_service.kong_proxy.load_balancer_ingress
  description = "Kong ingress proxy"
}
