resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "65.5.0"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.private_nodes,
    helm_release.loadbalancer_controller,
    kubernetes_namespace.monitoring
  ]

  values = [
    yamlencode({
      grafana = {
        service = {
          type = "ClusterIP"
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          hosts            = ["grafana.cloud2devops.online"]
          path             = "/"
          pathType         = "Prefix"
          annotations = merge(
            local.alb_annotations,
            {
              "alb.ingress.kubernetes.io/healthcheck-path" = "/api/health",
              "alb.ingress.kubernetes.io/group.order" = "5"
            }
          )
        }
      }

      prometheus = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
}


output "grafana_admin_password" {
  description = "Get Grafana admin password"
  value       = "kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d && echo"
}
