resource "google_compute_firewall" "allow-tag-http-public" {
  provider      = google
  name          = "${var.project_name}-ingress-tag-http-public"
  description   = "Allow HTTP to machines with the 'http-pub' tag"
  network       = module.vpc.network_name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-pub"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow-tag-https-public" {
  provider      = google
  name          = "${var.project_name}-ingress-tag-https-public"
  description   = "Allow HTTPS to machines with the 'https-pub' tag"
  network       = module.vpc.network_name
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-pub"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow-internal" {
  provider      = google
  name          = "${var.project_name}-ingress-internal"
  description   = "Allow ingress traffic from internal IP ranges"
  network       = module.vpc.network_name
  project       = var.project_id
  source_ranges = ["${var.network_priv_subnet_ip}/16"] 

  allow {
    protocol = "all"
  }
}