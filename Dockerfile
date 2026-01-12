# BUILD THE HYTALE SERVER IMAGE
FROM eclipse-temurin:25-jdk

RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    procps \
    jq \
    curl \
    unzip \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

LABEL maintainer="support@indifferentbroccoli.com" \
      name="indifferentbroccoli/hytale-server-docker" \
      github="https://github.com/indifferentbroccoli/hytale-server-docker" \
      dockerhub="https://hub.docker.com/r/indifferentbroccoli/hytale-server-docker"

# Create user/group
RUN groupadd -g 1001 hytale && \
    useradd -u 1001 -g 1001 -m -d /home/hytale -s /bin/bash hytale

ENV HOME=/home/hytale \
    CONFIG_DIR=/hytale-config \
    DEFAULT_PORT=5520 \
    SERVER_NAME=hytale-server \
    MAX_PLAYERS=20 \
    VIEW_DISTANCE=12 \
    ENABLE_BACKUPS=false \
    BACKUP_FREQUENCY=30 \
    DISABLE_SENTRY=true \
    USE_AOT_CACHE=true \
    AUTH_MODE=authenticated \
    ACCEPT_EARLY_PLUGINS=false \
    DOWNLOAD_ON_START=true \
    SESSION_TOKEN="" \
    IDENTITY_TOKEN="" \
    OWNER_UUID=""

COPY ./scripts /home/hytale/server/

COPY branding /branding

RUN mkdir -p /home/hytale/server-files && \
    chmod +x /home/hytale/server/*.sh && \
    chown -R 1001:1001 /home/hytale

WORKDIR /home/hytale/server

# Health check to ensure the server is running
HEALTHCHECK --start-period=5m \
            --interval=30s \
            --timeout=10s \
            CMD pgrep -f "HytaleServer.jar" > /dev/null || exit 1

ENTRYPOINT ["/home/hytale/server/init.sh"]
