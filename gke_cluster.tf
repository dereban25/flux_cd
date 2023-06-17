module "gke_cluster" {
  source           = "git::https://github.com/dereban25/prom-terra-modules.git//modules/eks"
  GOOGLE_REGION    = var.GOOGLE_REGION
  GOOGLE_PROJECT   = var.GOOGLE_PROJECT
  GKE_NUM_NODES    = 1
  GKE_MACHINE_TYPE = "e4-medium"
  DISK_SIZE_GB     = 20
  GKE_CLUSTER_NAME = "main"
}

resource "null_resource" "write_gke_context_to_file" {
  depends_on = [module.gke_cluster]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials main --zone us-central1 --project ${var.GOOGLE_PROJECT}"
  }
}
resource "null_resource" "add_fluxcd_helm" {
  depends_on = [module.gke_cluster]
  provisioner "local-exec" {
    command = "helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts"
  }
}
# module "gke-workload-identity" {
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   use_existing_k8s_sa = true
#   name                = "kustomize-controller"
#   namespace           = "flux-system"
#   project_id          = var.GOOGLE_PROJECT
#   cluster_name        = "main"
#   location            = var.GOOGLE_REGION
#   annotate_k8s_sa     = true
#   roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
# }


# module "kms" {
#   source          = "github.com/den-vasyliev/terraform-google-kms"
#   project_id      = var.GOOGLE_PROJECT
#   keyring         = "sops-flux"
#   location        = "global"
#   keys            = ["sops-key-flux"]
#   prevent_destroy = false
# }
