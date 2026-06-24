FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . ./
RUN npm run build

FROM nginx:alpine

RUN addgroup --system --gid 1001 nginxgroup
RUN adduser --system --uid 1001 nginxuser

COPY --from=builder --chown=nginxuser:nginxgroup /app/dist /usr/share/nginx/html

ARG APP_VERSION="1.0.0"
ARG COMMIT_SHA="unknown"
ARG BUILD_TIMESTAMP="unknown"
ARG IMAGE_DIGEST="unknown"
ARG SLSA_LEVEL="unknown"
ARG IMAGE_SIGNED="false"
ARG SBOM_ATTACHED="false"
ARG PROVENANCE_ATTACHED="false"

LABEL org.opencontainers.image.title="k8s-supply-chain" \
      org.opencontainers.image.description="Kubernetes Supply chain security" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${COMMIT_SHA}" \
      org.opencontainers.image.created="${BUILD_TIMESTAMP}" \
      org.opencontainers.image.source="https://github.com/davidlihor/k8s-supply-chain-security" \
      org.opencontainers.image.vendor="David Lihor"

ENV APP_VERSION=${APP_VERSION} \
    COMMIT_SHA=${COMMIT_SHA} \
    BUILD_TIMESTAMP=${BUILD_TIMESTAMP} \
    IMAGE_DIGEST=${IMAGE_DIGEST} \
    SLSA_LEVEL=${SLSA_LEVEL} \
    IMAGE_SIGNED=${IMAGE_SIGNED} \
    SBOM_ATTACHED=${SBOM_ATTACHED} \
    PROVENANCE_ATTACHED=${PROVENANCE_ATTACHED}

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY start.sh /start.sh

RUN chmod +x /start.sh

RUN sed -i 's/^user/#user/' /etc/nginx/nginx.conf && \
    sed -i '/^pid/d' /etc/nginx/nginx.conf && \
    echo "pid /tmp/nginx.pid;" >> /etc/nginx/nginx.conf

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run /usr/share/nginx/html && \
    chown -R nginxuser:nginxgroup /var/cache/nginx /var/log/nginx /var/run /usr/share/nginx/html

USER nginxuser
EXPOSE 8080

CMD ["/start.sh"]
