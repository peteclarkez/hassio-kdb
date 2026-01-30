#!/bin/bash
# KDB-X Tick System Startup for Home Assistant
# Starts tickerplant, RDB, HDB, and Gateway processes

set -e

# Set KDB-X environment variables explicitly
# (Dockerfile ENV may not be inherited in all cases)
export QHOME=/opt/kx
export QLIC=/opt/kx
export PATH="/opt/kx/bin:${PATH}"
export Q_TICKHOME=/opt/kx/kdb-tick

cd ${Q_TICKHOME}

# Source the license handler (reads KX_LICENSE_B64 from HA config)
if [[ -f "./kx-license.sh" ]]; then
    source ./kx-license.sh
fi

# HA data directory (persistent storage)
DATADIR=/data
LOGDIR=${DATADIR}/log
TPLOGDIR=${DATADIR}/tplog
HDBDIR=${DATADIR}/hass

# Create directories
mkdir -p ${LOGDIR} ${TPLOGDIR} ${HDBDIR}

# Ports
TICK_PORT=5010
RDB_PORT=5011
HDB_PORT=5012
GW_PORT=5013

echo "============================================="
echo "Starting KDB-X Tick for Home Assistant"
echo "============================================="
echo "Data directory: ${DATADIR}"
echo "HDB directory:  ${HDBDIR}"
echo "TP Log:         ${TPLOGDIR}"
echo ""
echo "Ports:"
echo "  Tickerplant: ${TICK_PORT}"
echo "  RDB:         ${RDB_PORT}"
echo "  HDB:         ${HDB_PORT}"
echo "  Gateway:     ${GW_PORT}"
echo "============================================="

# Export for q processes to use
export TICK_HDB_DIR="${HDBDIR}"
export TICK_SCRIPTS_DIR="./scripts"

# Initialize log files
touch ${LOGDIR}/tick.log ${LOGDIR}/rdb.log ${LOGDIR}/hdb.log ${LOGDIR}/gw.log

# Start Tickerplant (Port 5010)
# Uses hass.q schema from scripts/ directory
echo "Starting Tickerplant on port ${TICK_PORT}..."
nohup rlwrap q tick.q hass ${TPLOGDIR} -p ${TICK_PORT} \
    < /dev/null > ${LOGDIR}/tick.log 2>&1 &

# Wait for tickerplant to be ready
sleep 2

# Start RDB (Real-time Database) on port 5011
# Note: r.q expects ":port" format - it adds another colon internally
echo "Starting RDB on port ${RDB_PORT}..."
nohup rlwrap q tick/r.q ":${TICK_PORT}" ":${HDB_PORT}" -p ${RDB_PORT} \
    < /dev/null > ${LOGDIR}/rdb.log 2>&1 &

# Wait for RDB to be ready
sleep 1

# Start HDB (Historical Database) on port 5012
echo "Starting HDB on port ${HDB_PORT}..."
nohup rlwrap q tick/hdb.q "${HDBDIR}" -p ${HDB_PORT} \
    < /dev/null > ${LOGDIR}/hdb.log 2>&1 &

# Wait for HDB to be ready
sleep 1

# Start Gateway on port 5013
echo "Starting Gateway on port ${GW_PORT}..."
nohup rlwrap q tick/gw.q ":${RDB_PORT}" ":${HDB_PORT}" -p ${GW_PORT} \
    < /dev/null > ${LOGDIR}/gw.log 2>&1 &

# Wait for Gateway to be ready
sleep 1

echo ""
echo "============================================="
echo "KDB-X Tick System started successfully"
echo "============================================="
echo ""
echo "Process status:"
ps aux | grep -E "q.*(tick|r\.q|hdb|gw)" | grep -v grep || true
echo ""
echo "Tailing logs..."

# Keep container running and show all logs
tail -f ${LOGDIR}/tick.log ${LOGDIR}/rdb.log ${LOGDIR}/hdb.log ${LOGDIR}/gw.log
