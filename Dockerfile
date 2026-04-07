# ---------- STAGE 1: Builder ----------
FROM node:22-bookworm AS builder

WORKDIR /app

RUN npm install -g pnpm

# copy entire project FIRST
COPY . .

# now install deps (scripts folder exists)
RUN pnpm install --frozen-lockfile

RUN pnpm build


# ---------- STAGE 2: Production ----------
FROM node:22-bookworm-slim

WORKDIR /app

# install pnpm runtime only
RUN npm install -g pnpm

# copy only necessary files from builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/scripts ./scripts

ENV NODE_ENV=production

EXPOSE 8080

CMD ["node", "dist/index.js"]
