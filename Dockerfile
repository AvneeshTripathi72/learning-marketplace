# Stage 1: Build Flutter Web app inside Docker container using pre-built Flutter SDK
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS builder

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve compiled Flutter Web app using lightweight Nginx web server
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
