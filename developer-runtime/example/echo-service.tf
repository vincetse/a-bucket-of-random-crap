locals {
  echo_app_name = "echo"
  echo_namespace = "kx"
}

resource "kubernetes_deployment" "echo" {
  metadata {
    name = local.echo_app_name
    namespace = local.echo_namespace
    labels = {
      app = local.echo_app_name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.echo_app_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.echo_app_name
        }
      }
      spec {
        container {
          image = "gcr.io/kubernetes-e2e-test-images/echoserver:2.2"
          name = "echo"
          port {
            container_port = 8080
          }
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name = local.echo_app_name
    namespace = local.echo_namespace
    labels = {
      app = local.echo_app_name
    }
  }
  spec {
    selector = {
      app = local.echo_app_name
    }
    port {
      port = 8080
      name = "high"
      protocol = "TCP"
      target_port = 8080
    }
    port {
      port = 80
      name = "low"
      protocol = "TCP"
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress" "echo" {
  metadata {
    name = local.echo_app_name
    namespace = local.echo_namespace
  }
  spec {
    rule {
      http {
        path {
          path = "/echo"
          backend {
            service_name = local.echo_app_name
            service_port = 80
          }
        }
      }
    }
  }
}

output "echo_endpoint" {
  value = "http://${kubernetes_ingress.echo.load_balancer_ingress[0].ip}/echo"
  description = "Endpoint for the echo service"
}
