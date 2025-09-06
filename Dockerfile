# Stage 1: Build with Java
FROM openjdk:17-slim AS java-base
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Stage 2: Add Python and Firebase CLI
FROM python:3.13-slim
COPY --from=java-base /usr/local/openjdk-17 /usr/lib/jvm/
ENV JAVA_HOME=/usr/lib/jvm
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install build tools and Firebase CLI dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for Firebase CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Firebase CLI globally
RUN npm install -g firebase-tools

# Set working directory
WORKDIR /app

# Copy project files
COPY backend/ ./backend/
COPY firebase.json .

# Install Python dependencies
RUN pip install --no-cache-dir -r backend/requirements.txt

# Reinstall grpcio to ensure Cython extensions are built
RUN pip install --no-cache-dir --force-reinstall grpcio==1.74.0

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Command to start Firebase emulator
CMD ["sh", "-c", "firebase emulators:start --only functions,firestore,auth --project=fraud-detection-sys-5c342"]


