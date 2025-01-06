# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Install dependencies
COPY package*.json ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Install all dependencies including devDependencies
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration template
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Make necessary directories writable and set correct permissions
RUN mkdir -p /etc/nginx/conf.d /var/run/nginx /var/cache/nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d /var/run/nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html && \
    chmod -R 755 /etc/nginx/conf.d /var/run/nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html

# Switch to non-root user
USER nginx

# Use nginx's daemon-off option to run in foreground
CMD ["nginx", "-g", "daemon off;"]
