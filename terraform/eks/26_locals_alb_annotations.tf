locals {
  alb_annotations = {
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/group.name"  = "cloud2devops-ingress-alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"

    "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
      { HTTP = 80 },
      { HTTPS = 443 }
    ])
    "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
    "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
    "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
    "alb.ingress.kubernetes.io/success-codes"        = "200"
    "alb.ingress.kubernetes.io/group.order" = "1"
  }
}