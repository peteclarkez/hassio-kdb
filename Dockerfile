ARG BUILD_FROM
FROM $BUILD_FROM as base

####
FROM kxsys/embedpy as embedpy
#FROM peteclarkez/embedpypi as embedpy

#####
FROM base
# Setup base
#RUN apk add --no-cache jq git 
RUN apk add --no-cache curl ca-certificates \ 
        openssh-client\
		runit \
		unzip 

RUN apk --no-cache add rlwrap --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN passwd -d root
#RUN useradd -s /bin/bash -U -m kx

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --shell /bin/bash \
    # --ingroup "$USER" \
    # --no-create-home \
    kx

## Copy MiniConda Env
COPY --from=embedpy /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH

## Copy Q Env

COPY --from=embedpy /opt/kx/q /opt/kx/q
COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
COPY --from=embedpy /usr/local/bin/q /usr/local/bin/q
COPY --from=embedpy /init /init

ENV QHOME=/opt/kx/q

## Copy Tick Data Pipeline

ENV Q_TICKHOME=/opt/kx/kdb-tick

RUN mkdir -p $Q_TICKHOME/tick/

COPY --chown=kx bin/run.sh $Q_TICKHOME
COPY --chown=kx kdb-tick/*.q $Q_TICKHOME
COPY --chown=kx kdb-tick/tick/*.q $Q_TICKHOME/tick/

RUN chmod 774 $Q_TICKHOME && \
    chmod 774 $Q_TICKHOME/tick && \
    chown -R kx:kx $Q_TICKHOME

RUN mkdir -p /home/kx && chown -R kx:kx /home/kx

# ENTRYPOINT ["/init"]
# CMD ["/opt/kx/kdb-tick/run.sh"]

ENTRYPOINT ["/bin/bash"]
