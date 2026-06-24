#!/bin/sh

cat <<EOF > /usr/share/nginx/html/env.js
window.ENV = {
  API_URL: "${API_URL:-unknown}",
  CHAT_URL: "${CHAT_URL:-unknown}"
};
EOF

cat > /usr/share/nginx/html/healthz.json <<EOF
{
  "status": "healthy",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

cat > /usr/share/nginx/html/metadata.json <<EOF
{
  "build": {
    "image_digest": "${IMAGE_DIGEST:-unknown}",
    "commit_sha": "${COMMIT_SHA:-unknown}",
    "build_timestamp": "${BUILD_TIMESTAMP:-unknown}",
    "slsa_level": "${SLSA_LEVEL:-unknown}"
  },
  "attestations": {
    "signed": "${IMAGE_SIGNED:-false}",
    "sbom_attached": "${SBOM_ATTACHED:-false}",
    "provenance_attached": "${PROVENANCE_ATTACHED:-false}"
  }
}
EOF

echo "[INFO] Injected env.js, health.json, and metadata.json:"
cat /usr/share/nginx/html/env.js
cat /usr/share/nginx/html/health.json
cat /usr/share/nginx/html/metadata.json

exec nginx -g 'daemon off;'
