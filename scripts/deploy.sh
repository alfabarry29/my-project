#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || ! $1 =~ ^[0-9a-f]{40}$ ]]; then
    echo "Usage: $0 <published Git commit SHA>" >&2
    exit 1
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
image="ghcr.io/alfabarry29/my-project:$1"

kubectl set image --local -f "$repo_root/kubernetes/deployment.yaml" "my-app=$image" -o yaml |
    kubectl apply -f -
kubectl apply -f "$repo_root/kubernetes/service.yaml"
kubectl rollout status deployment/my-app --timeout=5m
