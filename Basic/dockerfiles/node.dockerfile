FROM node:0.10.43

ENV bundleFile=bundle.tar.gz

RUN mkdir /app
COPY bundle.tar.gz /app
WORKDIR /app
RUN tar -xf bundle.tar.gz
WORKDIR /app/bundle/programs/server
RUN npm    install 
WORKDIR /app/bundle
