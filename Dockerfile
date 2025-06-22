# Stage 1: Build the static site using Hugo
FROM klakegg/hugo:ext-alpine AS builder
WORKDIR /src
COPY ./blog-content /src
RUN hugo --baseURL="http://devopskelompok66.zapto.org/"

# Stage 2: Serve the static files using Nginx
FROM nginx:1.27-alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
