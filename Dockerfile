ARG BUILD_FROM
FROM $BUILD_FROM as base

####
# FROM kxsys/embedpy as embedpy
# FROM peteclarkez/embedpypi as embedpy

## Copy Tick Data Pipeline

ENV Q_TICKHOME=/opt/kx/kdb-tick

RUN mkdir -p $Q_TICKHOME/tick/
RUN mkdir -p $Q_TICKHOME/../data && chown -R kx:kx $Q_TICKHOME/../data

COPY --chown=kx bin/run.sh $Q_TICKHOME
COPY --chown=kx kdb-tick/*.q $Q_TICKHOME
COPY --chown=kx kdb-tick/tick/*.q $Q_TICKHOME/tick/

RUN chmod 774 $Q_TICKHOME && \
    chmod 774 $Q_TICKHOME/tick && \
    chown -R kx:kx $Q_TICKHOME

ENTRYPOINT ["/init"]
CMD ["/opt/kx/kdb-tick/run.sh"]

