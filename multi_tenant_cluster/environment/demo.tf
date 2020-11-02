
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment
resource "kubernetes_deployment" "demo-app" {
  metadata {
    name = "demo-app"
    namespace = "demo"
    labels = {
      app = "dummy-logger"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "dummy-logger"
      }
    }

    template {
      metadata {
        labels = {
          app = "dummy-logger"
        }
      }

      spec {
        container {
          image = "denniszielke/dummy-logger:latest"
          name  = "dummy-logger"

          resources {
            requests {
              cpu    = "100m"
              memory = "56Mi"
            }
            limits {
              cpu    = "200m"
              memory = "300Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service
resource "kubernetes_service" "demo-svc" {
  metadata {
    name = "dummy-svc"
    namespace = "demo"
  }
  spec {
    selector = {
      app = "dummy-logger"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
resource "kubernetes_ingress" "appgw-ingress" {
  metadata {
    name = "appgw-ingress"
    namespace = "demo"
    annotations = {
      "kubernetes.io/ingress.class" = "azure/application-gateway"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "dummy-svc"
            service_port = 80
          }
        }
      }
    }
  }
}


# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
resource "kubernetes_ingress" "traefik-ingress" {
  metadata {
    name = "traefik-ingress"
    namespace = "demo"
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {

    rule {
      http {
        path {
          backend {
            service_name = "dummy-svc"
            service_port = 80
          }
        }
      }
    }
  }
}