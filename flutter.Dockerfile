FROM debian:bullseye-slim

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="$PATH:/flutter/bin:/flutter/.pub-cache/bin"

# Set working directory
WORKDIR /app

# Copy the entire project (fraud_detection_sys) to the working directory
COPY . .

# Build Flutter web app
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web

# Serve the web app with a simple server
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]