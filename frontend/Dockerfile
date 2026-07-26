FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --ignore-scripts
COPY . .
RUN npm run build

FROM nginx:alpine AS production
RUN addgroup -S nginxgroup && adduser -S nginxuser -G nginxgroup && \
    chown -R nginxuser:nginxgroup /usr/share/nginx/html && \
    chown -R nginxuser:nginxgroup /var/cache/nginx && \
    chown -R nginxuser:nginxgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginxuser:nginxgroup /var/run/nginx.pid
COPY --from=build /app/build /usr/share/nginx/html
USER nginxuser
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]