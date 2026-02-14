# =============================================================================
# Stage 1: Get KDB-X tick system from kdbx-tick image
# =============================================================================
#FROM kdbx-tick:latest AS kdbx
FROM peteclarkez/kdbx-tick:5.0.5 AS kdbx

# =============================================================================
# Stage 2: Home Assistant runtime
# =============================================================================
FROM homeassistant/amd64-base-debian:bookworm

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    lsof \
    procps \
    rlwrap \
    && rm -rf /var/lib/apt/lists/*

# Copy KDB-X installation from kdbx-tick image
# KDB-X is installed in /home/kdb/.kx in the source image
COPY --from=kdbx /home/kdb/.kx /opt/kx

# Copy tick system scripts from kdbx-tick image
COPY --from=kdbx /opt/kx/kdb-tick /opt/kx/kdb-tick

# Environment variables for KDB-X
ENV QHOME=/opt/kx
ENV QLIC=/opt/kx
ENV PATH="/opt/kx/bin:${PATH}"
ENV Q_TICKHOME=/opt/kx/kdb-tick

# Create directories for tick system
RUN mkdir -p ${Q_TICKHOME}/scripts \
    /data/log \
    /data/tplog \
    /data/hass

# Copy HA-specific bootstrap wrapper
COPY bin/run.sh ${Q_TICKHOME}/
RUN chmod +x ${Q_TICKHOME}/run.sh

# Copy Home Assistant schema (hass.q replaces sym.q for HA integration) and custom q files
COPY scripts/*.q ${Q_TICKHOME}/scripts/

# Home Assistant add-on labels
ARG BUILD_VERSION=dev
ARG BUILD_ARCH=amd64
LABEL io.hass.version="${BUILD_VERSION}"
LABEL io.hass.type="addon"
LABEL io.hass.arch="${BUILD_ARCH}"

# Expose ports: Tickerplant, RDB, HDB, Gateway
EXPOSE 5010 5011 5012 5013

# Volume for persistent data
VOLUME /data

# Healthcheck - verify tickerplant port is open
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD lsof -i :5010 | grep -q LISTEN || exit 1

# Set working directory
WORKDIR ${Q_TICKHOME}

# Default command
CMD ["/opt/kx/kdb-tick/run.sh"]
