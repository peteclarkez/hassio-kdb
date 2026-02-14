#!/bin/bash
# Home Assistant bootstrap wrapper for kdb-tick's tick.sh
# Reads HA add-on config, sets environment variables, then delegates to tick.sh

set -e

# Read KX license from Home Assistant add-on options
CONFIG_PATH=/data/options.json
export KX_LICENSE_B64=$(jq --raw-output '.KX_LICENSE_B64 // empty' $CONFIG_PATH)

# Set KDB-X environment variables explicitly
# (Dockerfile ENV may not be inherited in all cases)
export QHOME=/opt/kx
export QLIC=/opt/kx
export PATH="/opt/kx/bin:${PATH}"
export Q_TICKHOME=/opt/kx/kdb-tick

# HA add-ons use /data as the single persistent volume,
# so override the default mount points to subdirs under /data
export TICK_DATA_DIR=/data/hass
export TICK_LOG_DIR=/data/log
export TICK_TPLOG_DIR=/data/tplog
export TICK_SCRIPTS_DIR=/opt/kx/kdb-tick/scripts

# Use hass.q schema instead of default sym.q
export TICK_SCHEMA=hass

# Delegate to the upstream tick.sh
exec /opt/kx/kdb-tick/tick.sh
