ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

USER root   
WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

# Copiar archivos del proyecto
COPY src src
COPY module.xml module.xml
COPY iris.script /tmp/iris.script

# Instalar y configurar
RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
