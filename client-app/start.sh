#!/bin/sh

cat <<EOF > /usr/share/nginx/html/env.js
window.ENV = {
  API_URL: "${API_URL}",
  CHAT_URL: "${CHAT_URL}"
};
EOF

echo "[INFO] Injected env.js:"
cat /usr/share/nginx/html/env.js

exec nginx -g 'daemon off;'