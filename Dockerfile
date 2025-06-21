# Stage 1: Build the static site using Hugo
FROM klakegg/hugo:ext-alpine AS builder
WORKDIR /src
COPY ./blog-content /src
RUN hugo

# Stage 2: Serve the static files using Nginx
FROM nginx:1.27-alpine
# Salin hasil build dari stage sebelumnya
COPY --from=builder /src/public /usr/share/nginx/html
# Ekspos port 80
EXPOSE 80
# Perintah untuk menjalankan Nginx saat container dimulai
CMD ["nginx", "-g", "daemon off;"]