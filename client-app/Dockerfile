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
