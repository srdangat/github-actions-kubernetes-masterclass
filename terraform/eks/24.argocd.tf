resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.9.0"

  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  wait    = true
  timeout = 600

  replace = true

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.private_nodes,
    helm_release.loadbalancer_controller,
    kubernetes_namespace.argocd
  ]

  values = [
    yamlencode({

      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        service = {
          type = "ClusterIP"
        }

        ingress = {
          enabled          = true
          ingressClassName = "alb"

          hosts = [
            "argocd.cloud2devops.online"
          ]

          path     = "/"
          pathType = "Prefix"

          annotations = merge(
            local.alb_annotations,
            {
              "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz",
              "alb.ingress.kubernetes.io/group.order" = "10"
            }
          )
        }
      }
    })
  ]
}

output "argocd_initial_password" {
  description = "Get ArgoCD admin password"
  value       = "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d && echo"
}