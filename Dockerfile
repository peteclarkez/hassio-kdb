# ARG BUILD_FROM
# FROM $BUILD_FROM as base

FROM "homeassistant/armv7-base-debian:buster" as base
# FROM "homeassistant/amd64-base-debian:buster" as base

####
FROM peteclarkez/embedpypi as embedpy
# FROM kxsys/embedpy as embedpy

#####
FROM base
####
RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \	   
		ca-certificates \
		curl \
	&& apt-get clean \	
 	&& find /var/lib/apt/lists -type f -delete
#rlwrap
#		unzip \	

## Copy Tick Data Pipeline

#LABEL io.hass.version="VERSION" 
LABEL io.hass.version="35.0.3" 
LABEL io.hass.type="addon" 
LABEL io.hass.arch="armv7|amd64"

## Copy MiniConda Env
COPY --from=embedpy /opt/conda /opt/conda
COPY --from=embedpy /usr/local/bin/q /usr/local/bin/q
COPY --from=embedpy /etc/profile.d/kx.sh /etc/profile.d/kx.sh
RUN cat /etc/profile.d/kx.sh >> /root/.bashrc
#COPY --from=embedpy /init /init

ENV QHOME=/opt/kx/q

COPY --from=embedpy /opt/kx/q /opt/kx/q

ENV CONDAHOME=/opt/conda
ENV PATH=${CONDAHOME}/bin:${QHOME}/l32:${QHOME}/l32arm:${QHOME}/l64:$PATH

###
ENV Q_TICKHOME=/opt/kx/kdb-tick

RUN mkdir -p $Q_TICKHOME/tick/
RUN mkdir -p $Q_TICKHOME/../data

COPY bin/run.sh $Q_TICKHOME
COPY kdb-tick/*.q $Q_TICKHOME
COPY kdb-tick/tick/*.q $Q_TICKHOME/tick/
RUN chmod a+x ${Q_TICKHOME}/run.sh



#RUN $CONDAHOME/bin/conda create  -y -n kx python=3 --no-default-packages
#RUN chmod a+x /usr/local/bin/q

EXPOSE 5010 5011 5012
VOLUME /data

#ENTRYPOINT ["/init"]
CMD ["/opt/kx/kdb-tick/run.sh"]

#TODO RUN AS ROOT