# Use Node.js base image with Python
FROM node:20-bullseye

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY pizzaz_server_python/requirements.txt ./pizzaz_server_python/

# Install Node.js dependencies
RUN pnpm install --frozen-lockfile

# Install Python dependencies
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r pizzaz_server_python/requirements.txt

# Copy application code
COPY . .

# Set BASE_URL and build
ARG BASE_URL=https://openai-apps-sdk-examples-production-5f32.up.railway.app
ENV BASE_URL=$BASE_URL
RUN pnpm run build

# Expose port
EXPOSE 8000

# Start command - run both servers
CMD pnpm run serve & /opt/venv/bin/uvicorn pizzaz_server_python.main:app --host 0.0.0.0 --port $PORT
