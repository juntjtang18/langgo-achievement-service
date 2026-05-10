FROM node:20-bookworm-slim AS build
WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json* tsconfig.json ./
RUN npm install

COPY src ./src
COPY test ./test
COPY sql ./sql
COPY backup ./backup
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
COPY --from=build /app/backup ./backup
COPY --from=build /app/README.md ./
COPY --from=build /app/.env.example ./

EXPOSE 8080
CMD ["npm", "run", "start"]
