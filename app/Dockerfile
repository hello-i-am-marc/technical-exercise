# Build stage: full image with npm to install deps
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

# Runtime stage: same base but with npm/yarn stripped out
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY server.js ./
COPY wizexercise.txt ./
# npm and yarn aren't needed at runtime; remove to clear vulnerabilities in their bundled deps
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /opt/yarn-* \
           /usr/local/bin/yarn \
           /usr/local/bin/yarnpkg
EXPOSE 3000
USER node
CMD ["node", "server.js"]