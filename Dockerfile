# use ZAP as base image
FROM softwaresecurityproject/zap-stable

# define ZAP api key, web server file path and web server port
ENV API_KEY=93bd5953-5d0a-4679-a52a-87a55033238b
ENV WS_FILE_PATH=/tmp/config.yml
ENV WS_PORT=8181

# expose ZAP_PORT and PORT
EXPOSE ${ZAP_PORT} ${WS_PORT}

# set the user to root
USER root

# instll curl & nodejs
RUN apt-get install -y curl &&\
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs

# set the workdir to the yml api
WORKDIR /srv/ymlapi

# copy packages
COPY ./dist ./dist
COPY package.json .
COPY tsconfig.json .

# install NPM packages
RUN npm install

# copy the init.sh to root and make executable
COPY init.sh /
RUN chmod +x /init.sh

# run the init
CMD /init.sh