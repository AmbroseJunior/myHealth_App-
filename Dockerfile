# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Build Flutter Web
# ─────────────────────────────────────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.35.7 AS builder

WORKDIR /app

# Copy dependency manifests first — cache pub get when only code changes
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get --no-example

# Copy remaining source (assets, lib, web, l10n)
COPY . .

# Build optimised web release
RUN flutter build web \
      --release \
      --no-tree-shake-icons \
      --base-href /

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Serve with nginx (alpine, ~8 MB final image)
# ─────────────────────────────────────────────────────────────────────────────
FROM nginx:1.27-alpine AS runner

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy Flutter web build from stage 1
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# nginx runs in foreground so Docker can manage the process
CMD ["nginx", "-g", "daemon off;"]
