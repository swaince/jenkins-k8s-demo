FROM maven:3.6.1-jdk-8-alpine

WORKDIR /usr/share/maven
RUN mkdir repo \
&& rm conf/settings.xml
COPY settings.xml conf/settings.xml
