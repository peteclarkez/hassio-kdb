ARG BUILD_FROM
FROM $BUILD_FROM as base

####
# FROM kxsys/embedpy as embedpy
# FROM peteclarkez/embedpypi as embedpy

## Copy Tick Data Pipeline

#LABEL io.hass.version="VERSION" 
LABEL io.hass.version="3.11" 
LABEL io.hass.type="addon" 
#LABEL io.hass.arch="armhf|aarch64|i386|amd64"
LABEL io.hass.arch="armv7l|amd64"


ENV Q_TICKHOME=/opt/kx/kdb-tick

RUN mkdir -p $Q_TICKHOME/tick/
RUN mkdir -p $Q_TICKHOME/../data && chown -R kx:kx $Q_TICKHOME/../data

COPY --chown=kx bin/run.sh $Q_TICKHOME
COPY --chown=kx kdb-tick/*.q $Q_TICKHOME
COPY --chown=kx kdb-tick/tick/*.q $Q_TICKHOME/tick/

RUN chmod 774 $Q_TICKHOME && \
    chmod 774 $Q_TICKHOME/tick && \
    chown -R kx:kx $Q_TICKHOME

EXPOSE 5010 5011 5012
VOLUME /data

ENTRYPOINT ["/init"]
CMD ["/opt/kx/kdb-tick/run.sh"]

#TODO RUN AS ROOT