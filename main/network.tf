module "vpc" {
  providers = {
    google = google
  }
  source                    = "../modules/gcp-network-module"
  
  network_name              = "${var.project_name}-${var.env}-vpc-01"
  project_id                = var.project_id
  
  subnets                   = [
    {
      subnet_name           = "${var.project_name}-${var.env}-apps-private-subnet-01"
      subnet_ip             = "${var.network_priv_subnet_ip}/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = "${var.project_name}-${var.env}-apps-public-subnet-02"
      subnet_ip             = "${var.network_pub_subnet_ip}/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
        "${var.project_name}-${var.env}-apps-private-subnet-01" = [
            {
                range_name    = "${var.project_name}-${var.env}-apps-private-subnet-01-secondary-01"
                ip_cidr_range = "${var.network_2nd_subnet_ip}/21"
            },
        ]
  }

routes                       = [
    {
      name                   = "egress-internet"
      description            = "Route through IGW to access internet"
      destination_range      = "0.0.0.0/0"
      next_hop_internet      = "true"
    }
  ] 
}


resource "google_compute_router" "vpc_router" {
  name = "${var.project_name}-${var.env}-router"

  project = var.project_id
  region  = var.region
  network = module.vpc.network_self_link
}

resource "google_compute_router_nat" "vpc_nat" {
  name = "${var.project_name}-${var.env}-nat"

  project = var.project_id
  region  = var.region
  router  = google_compute_router.vpc_router.name

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "${var.project_name}-${var.env}-apps-private-subnet-01"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}