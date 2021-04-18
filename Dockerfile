FROM python:3-stretch
LABEL maintainer="luca.lianas@crs4.it"

RUN mkdir -p /home/ome-seadragon

RUN groupadd ome-seadragon && useradd -g ome-seadragon ome-seadragon

ENV HOME=/home/ome-seadragon
ENV APP_HOME=/home/ome-seadragon/app
RUN mkdir $APP_HOME \
    && chown -R ome-seadragon ${APP_HOME}
WORKDIR $APP_HOME

ARG OME_SEADRAGON_GW_VERSION=0.2.2

USER ome-seadragon

RUN wget https://github.com/crs4/ome_seadragon_gateway/archive/v${OME_SEADRAGON_GW_VERSION}.zip -P ${APP_HOME} \
    && unzip ${APP_HOME}/v${OME_SEADRAGON_GW_VERSION}.zip -d ${APP_HOME} \
    && mv ${APP_HOME}/ome_seadragon_gateway-${OME_SEADRAGON_GW_VERSION} ${APP_HOME}/ome_seadragon_gateway \
    && rm ${APP_HOME}/v${OME_SEADRAGON_GW_VERSION}.zip

USER root

WORKDIR ${APP_HOME}/ome_seadragon_gateway/

RUN pip install -r requirements_pg.txt \
    && pip install gunicorn==19.9.0

COPY resources/entrypoint.sh \
     resources/wait-for-it.sh \
     /usr/local/bin/

COPY resources/80-apply-migrations.sh \
     resources/99-run.sh \
     /startup/

USER ome-seadragon

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
