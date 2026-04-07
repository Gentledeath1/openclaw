# ---------- STAGE 1: Builder ----------
FROM node:20-bookworm AS builder

WORKDIR /app

# install pnpm
RUN npm install -g pnpm

# copy dependency files first (better caching)
COPY package.json pnpm-lock.yaml* ./

RUN pnpm install --frozen-lockfile

# copy project
COPY . .

# build project
RUN pnpm build


# ---------- STAGE 2: Production ----------
FROM node:20-bookworm-slim

WORKDIR /app

# install pnpm runtime only
RUN npm install -g pnpm

# copy only necessary files from builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production

EXPOSE 8080

CMD ["node", "dist/index.js"]
