FROM python:2-stretch
LABEL maintainerb="luca.lianas@crs4.it"

RUN mkdir -p /home/ome-seadragon

RUN groupadd ome-seadragon && useradd -g ome-seadragon ome-seadragon

ENV HOME=/home/ome-seadragon
ENV APP_HOME=/home/ome-seadragon/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ARG OME_SEADRAGON_GW_VERSION=0.1.2

RUN wget https://github.com/crs4/ome_seadragon_gateway/archive/v${OME_SEADRAGON_GW_VERSION}.zip -P /home/ome-seadragon/app/ \
    && unzip /home/ome-seadragon/app/v${OME_SEADRAGON_GW_VERSION}.zip -d /home/ome-seadragon/app/ \
    && mv /home/ome-seadragon/app/ome_seadragon_gateway-${OME_SEADRAGON_GW_VERSION} /home/ome-seadragon/app/ome_seadragon_gateway \
    && rm /home/ome-seadragon/app/v${OME_SEADRAGON_GW_VERSION}.zip \
    && chown -R ome-seadragon ${APP_HOME}

WORKDIR /home/ome-seadragon/app/ome_seadragon_gateway/

RUN pip install -r requirements_pg.txt \
    && pip install gunicorn==19.9.0

COPY resources/entrypoint.sh \
     resources/wait-for-it.sh \
     /usr/local/bin/

COPY resources/80-apply-migrations.sh \
     resources/99-run.sh \
     /startup/

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
