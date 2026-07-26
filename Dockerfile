FROM node:18-alpine AS base
WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY backend ./backend
COPY uploads ./uploads

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 5000
CMD [ "node", "backend/server.js"  ]