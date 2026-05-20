#!/bin/bash

set -e

echo "===================================="
echo "Creating namespace: monitoring"
echo "===================================="

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "===================================="
echo "Installing Grafana (via Helm)"
echo "===================================="

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.service.type=ClusterIP

echo ""
echo "===================================="
echo "Waiting for Grafana to be ready..."
echo "===================================="

kubectl rollout status deployment kube-prometheus-stack-grafana -n monitoring --timeout=300s

echo ""
echo "===================================="
echo "Fetching Grafana Admin Password"
echo "===================================="

DEFAULT_PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 --decode)

echo ""
echo "===================================="
echo "Grafana Access Info"
echo "===================================="

echo "Grafana UI Access:"
echo "    kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80"
echo "    Then open: http://localhost:3000"
echo ""

echo "Login Credentials:"
echo "    Username: admin"
echo "    Password: $DEFAULT_PASSWORD"
echo ""