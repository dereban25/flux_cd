provider "google" {
  project = var.GOOGLE_PROJECT
  region  = var.GOOGLE_REGION
}
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "gke_kuber-351315_us-central1_maks-test"
  }
}
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
    }
  }
  backend "gcs" {
    bucket = "terraform-maks"
    prefix = "kubertest/state"
  }
}

module "gke_cluster" {
  source         = "git::https://github.com/dereban25/prom-terra-modules.git//modules/eks"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 1
  GKE_MACHINE_TYPE = "e2-medium"
  DISK_SIZE_GB = 20
  GKE_CLUSTER_NAME = "maks-test"
}

resource "null_resource" "write_gke_context_to_file" {
    depends_on = [ module.gke_cluster]
    provisioner "local-exec" {
        command = "gcloud container clusters get-credentials maks-test --zone us-central1 --project ${var.GOOGLE_PROJECT}"
    }
}
resource "null_resource" "add_fluxcd_helm" {
    depends_on = [ module.gke_cluster]
    provisioner "local-exec" {
        command = "helm repo remove fluxcd-community https://fluxcd-community.github.io/helm-charts"
    }
}

resource "helm_release" "fluxcd" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
}