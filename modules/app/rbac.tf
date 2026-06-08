resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}

# Intentional misconfig per exercise requirement:
# "Container application must be assigned a cluster-wide kubernetes admin role and privilege"
resource "kubernetes_cluster_role_binding" "app_cluster_admin" {
  metadata {
    name = "app-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app.metadata[0].name
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}