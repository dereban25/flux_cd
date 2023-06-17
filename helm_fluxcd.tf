resource "helm_release" "fluxcd" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
}

resource "flux_bootstrap_git" "kube_prometheus" {
  path = "./manifests/monitoring/kube-prometheus-stack"
}
resource "flux_bootstrap_git" "loki_stack" {
  path = "./manifests/monitoring/loki-stack"
  depends_on = [ flux_bootstrap_git.kube_prometheus ]
}
resource "flux_bootstrap_git" "monitoring_config" {
  path = "./manifests/monitoring/monitoring-config"
  depends_on = [ flux_bootstrap_git.loki_stack ]
}
resource "flux_bootstrap_git" "tempo" {
  path = "./manifests/monitoring/monitoring-config"
  depends_on = [ flux_bootstrap_git.loki_stack ]
}