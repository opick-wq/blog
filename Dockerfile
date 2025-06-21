# Stage 1: Build the static site using Hugo
FROM klakegg/hugo:ext-alpine AS builder

WORKDIR /src

# Pastikan kamu menyalin semua file Hugo, bukan hanya `blog-content`
COPY . .

# Opsional: Override baseURL dari ENV
ARG HUGO_BASEURL=http://192.168.49.2:31401/
RUN hugo --baseURL=${HUGO_BASEURL}

# Stage 2: Serve the static files using Nginx
FROM nginx:1.27-alpine

# Bersihkan default halaman Nginx (opsional tapi aman)
RUN rm -rf /usr/share/nginx/html/*

# Salin hasil build dari stage sebelumnya
COPY --from=builder /src/public /usr/share/nginx/html

# Ekspos port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
