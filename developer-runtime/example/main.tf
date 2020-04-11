provider "kubernetes" {}

module "runtime" {
  source = "./.."
}

output "hephy_workflow_router" {
  value = module.runtime.hephy_workflow_router
}

output "kong_proxy" {
  value = module.runtime.kong_proxy
}
