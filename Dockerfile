# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS build
WORKDIR /app

COPY package.json package-lock.json* tsconfig.json ./
COPY vendor ./vendor
RUN --mount=type=cache,target=/root/.npm npm ci

COPY src ./src
COPY sql ./sql
COPY README.md ./
COPY .env.example ./

RUN npm run build && npm prune --omit=dev

FROM node:20-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/sql ./sql
COPY --from=build /app/README.md ./
COPY --from=build /app/.env.example ./

EXPOSE 8080
CMD ["npm", "run", "start"]
