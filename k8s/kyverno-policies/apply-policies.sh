#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying Kyverno supply chain security policies..."

if ! kubectl get namespace kyverno &>/dev/null; then
  echo "Error: Kyverno namespace not found. Please install Kyverno first."
  exit 1
fi

echo "Verifying Kyverno controller status..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/component=admission-controller \
  -n kyverno --timeout=60s

POLICIES=(
  "restrict-image-registries.yaml"
  "require-security-context.yaml"
  "verify-image-signature.yaml"
  "verify-slsa-provenance.yaml"
  "verify-sbom-attestation.yaml"
)

echo "Applying ${#POLICIES[@]} cluster policies..."
for policy in "${POLICIES[@]}"; do
  policy_path="${SCRIPT_DIR}/${policy}"
  if [ -f "$policy_path" ]; then
    echo "  → ${policy}"
    kubectl apply -f "$policy_path"
  else
    echo "  ⚠ Skipping ${policy} (file not found)"
  fi
done

echo "Waiting for policies to be ready..."
sleep 3

echo "Current cluster policies:"
kubectl get clusterpolicy -o custom-columns=NAME:.metadata.name,BACKGROUND:.spec.background,VALIDATION:.spec.validationFailureAction

echo "✓ Supply chain security policies are now active"
echo "Test policy enforcement:"
echo "  kubectl run test-unsigned --image=nginx -n reactivities"
echo "  Expected: admission webhook denies unsigned image"
