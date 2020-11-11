#!/bin/bash 
cd /opt/kx/kdb-tick

export LOGDIR=../data/log
export DATADIR=../data
export TICKSRC=hass

mkdir -p ${DATADIR}/tplog
mkdir -p ${DATADIR}/hass
mkdir -p ${LOGDIR}
touch ${LOGDIR}/tick.log

#Tick
nohup q tick.q ${TICKSRC} ${DATADIR}/tplog        -p 5010 < /dev/null > ${LOGDIR}/tick.log 2>&1 &  
#RDB
nohup q tick/r.q :5010 :5012 ${DATADIR}/${TICKSRC} -p 5011 < /dev/null > ${LOGDIR}/rdb.log 2>&1 &
#HDB
nohup q ${DATADIR}/${TICKSRC}                      -p 5012 < /dev/null > ${LOGDIR}/hdb.log 2>&1 &
#Gateway
#nohup q tick/gw.q     -p 5013 < /dev/null > ${LOGDIR}/gw.log 2>&1 &
#HouseKeeping
#nohup q tick/hk.q     -p 5014 < /dev/null > ${LOGDIR}/hk.log 2>&1 &
#Feedhanler
#nohup q tick/feed.q  < /dev/null > ${LOGDIR}feed.log 2>&1 &

tail -f ${LOGDIR}/tick.log