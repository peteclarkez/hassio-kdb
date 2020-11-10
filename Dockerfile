ARG BUILD_FROM
FROM $BUILD_FROM as base

####

FROM peteclarkez/kdb-tick-docker as kdbtick
####
FROM kxsys/embedpy as embedpy
#FROM peteclarkez/embedpypi as embedpy

#####
FROM base
# Setup base
RUN apk add --no-cache jq curl git openssh-client

# RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
# 		ca-certificates \
# 		curl \
# 		rlwrap \
# 		unzip \
# 	&& apt-get clean \
# 	&& find /var/lib/apt/lists -type f -delete

# Home Assistant CLI
# ARG BUILD_ARCH
# ARG CLI_VERSION
# RUN curl -Lso /usr/bin/ha \
#         "https://github.com/home-assistant/cli/releases/download/${CLI_VERSION}/ha_${BUILD_ARCH}" \
#     && chmod a+x /usr/bin/ha
# Copy data
# COPY data/run.sh /
# CMD [ "/run.sh" ]


## Copy MiniConda Env
COPY --from=embedpy /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH

#COPY --from=embedpy /opt/miniconda /opt/miniconda
#ENV PATH=/opt/miniconda/bin:$PATH

## Copy Q Env

COPY --from=embedpy /opt/kx/q /opt/kx/q
COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
COPY --from=embedpy /usr/local/bin/q /usr/local/bin/q
COPY --from=embedpy /init /init

ENV QHOME=/opt/kx/q

## Copy Tick Data Pipeline

ENV Q_TICKHOME=/opt/kx/kdb-tick

COPY --from=kdbtick $Q_TICKHOME $Q_TICKHOME

# RUN chmod 774 $Q_TICKHOME && \
#     chmod 774 $Q_TICKHOME/tick && \
#     chmod a+x /opt/kx/kdb-tick/tick.sh && \ 
#     chown -R kx:kx $Q_TICKHOME

ENTRYPOINT ["/init"]
CMD ["/opt/kx/kdb-tick/tick.sh"]
