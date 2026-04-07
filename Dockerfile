# Stage 1: Base Node image
FROM node:24-bookworm AS base

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    procps hostname curl git lsof openssl && \
    rm -rf /var/lib/apt/lists/*

# Install Bun (optional, if your project uses Bun)
RUN set -eux; \
    for attempt in 1 2 3 4 5; do \
        if curl --retry 5 --retry-all-errors --retry-delay 2 -fsSL https://bun.sh/install | bash; then break; fi; \
        if [ "$attempt" -eq 5 ]; then exit 1; fi; \
        sleep $((attempt * 2)); \
    done
ENV PATH="/root/.bun/bin:$PATH"

# Stage 2: Copy project files
COPY package.json package-lock.json* ./ 
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts
COPY extensions ./extensions

RUN corepack enable

# Stage 3: Install dependencies
RUN pnpm install
RUN chmod +x node_modules/.bin/*

# Stage 4: Build/Bundle project
# Adjust these according to your project needs
RUN corepack enable
RUN pnpm canvas:a2ui:bundle || \
    (echo "A2UI bundle: creating stub (non-fatal)" && \
     mkdir -p src/canvas-host/a2ui && \
     echo "/* A2UI bundle unavailable */" > src/canvas-host/a2ui/a2ui.bundle.js && \
     echo "stub" > src/canvas-host/a2ui/.bundle.hash)

# Stage 5: Permissions fix
RUN chown -R node:node /app && \
    find /app -type d -exec chmod 755 {} + && \
    find /app -type f -exec chmod 644 {} +

# Stage 6: Set working user
USER node
WORKDIR /app

# Stage 7: Expose and run
EXPOSE 3000
CMD ["npm", "start"]
