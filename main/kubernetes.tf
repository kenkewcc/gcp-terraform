data "google_compute_subnetwork" "apps-1" {
  name   = "${var.project_name}-${var.env}-apps-private-subnet-01"
  region = var.region
}

module "gke-private" {
  providers = {
    google = google
  }
  source                          = "../modules/gcp-gke-module"
  region                          = var.region
  project_name                    = var.project_name
  env                             = var.env
  cluster_name                    = "${var.project_name}-${var.env}-private-cluster"
  network                         = module.vpc.network_self_link
  subnetwork                      = data.google_compute_subnetwork.apps-1.self_link
  min_master_version              = "1.15.11-gke.15"
  default_max_pods_per_node       = 110
  subnetwork_secondary_range_name = "${var.project_name}-${var.env}-apps-private-subnet-01-secondary-01"

  ##GKE NODE
  cluster_node_name               = "${var.project_name}-${var.env}-private-general"
  general_purpose_machine_type    = "e2-standard-2"
  general_purpose_min_node_count  = 2
  general_purpose_max_node_count  = 2
  master_ipv4_cidr_block          = "${var.master_cidr_subnet_ip}/28"
}


resource "kubernetes_ingress" "gke_ingress" {
  metadata {
    name = "gke-ingress"
  }

  spec {
    backend {
      service_name = "myapp-1"
      service_port = 8080
    }

    rule {
      host = "web-1.example.com"
      http {
        path {
          backend {
            service_name = "myapp-1"
            service_port = 8080
          }

          path = "/app1/*"
        }

        path {
          backend {
            service_name = "myapp-2"
            service_port = 8080
          }

          path = "/app2/*"
        }
      }
    }

    rule {
      host = "web-2.example.com"
      http {
        path {
          backend {
            service_name = "myapp-3"
            service_port = 8080
          }

          path = "/app3/*"
        }

        path {
          backend {
            service_name = "myapp-4"
            service_port = 8080
          }

          path = "/app4/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}