FROM node:20-slim

# Enable pnpm via corepack
RUN corepack enable

WORKDIR /app

# Copy only package files first (better cache)
COPY package.json pnpm-lock.yaml* ./

# Install deps using pnpm
RUN pnpm install --frozen-lockfile

# Copy remaining files
COPY . .

# ✅ FIX: ensure binaries are executable
RUN chmod -R +x node_modules/.bin

# Build project
RUN pnpm build

EXPOSE 3000

CMD ["npm", "start"]
