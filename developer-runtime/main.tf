################################################################################
# namespaces
locals {
  ns_hephy_workflow = "deis"
  ns_kong = "kx"
}

################################################################################
# Hephy Workflow
resource "kubernetes_namespace" "heply_workflow" {
  metadata {
    annotations = {
      name = local.ns_hephy_workflow
    }
    name  = local.ns_hephy_workflow
  }
}

data "helm_repository" "hephy" {
  name = "hephy"
  url  = "https://charts.teamhephy.com"
}

resource "helm_release" "hephy_workflow" {
  name = local.ns_hephy_workflow
  repository = data.helm_repository.hephy.metadata[0].name
  chart = "hephy/workflow"
  namespace = local.ns_hephy_workflow

  set {
    name = "global.use_rbac"
    value = "true"
  }

  set {
    name = "global.use_cni"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.heply_workflow
  ]
}

data "kubernetes_service" "hephy_workflow_router" {
  metadata {
    name = "${local.ns_hephy_workflow}-router"
    namespace = local.ns_hephy_workflow
  }

  depends_on = [
    helm_release.hephy_workflow,
  ]
}

################################################################################
# Kong ingress
resource "kubernetes_namespace" "kong" {
  metadata {
    annotations = {
      name = local.ns_kong
    }
    name  = local.ns_kong
  }
}

data "helm_repository" "kong" {
  name = "kong"
  url  = "https://charts.konghq.com"
}

resource "helm_release" "kong" {
  name = local.ns_kong
  repository = data.helm_repository.kong.metadata[0].name
  chart = "kong/kong"
  namespace = local.ns_kong

  set {
    name = "ingressController.installCRDs"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace.kong,
  ]
}

data "kubernetes_service" "kong_proxy" {
  metadata {
    name = "${local.ns_kong}-kong-proxy"
    namespace = local.ns_kong
  }

  depends_on = [
    helm_release.kong,
  ]
}
