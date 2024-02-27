# use ZAP as base image
FROM --platform=linux/amd64 softwaresecurityproject/zap-stable:2.14.0

# define ZAP api key, web server file path and web server port
ENV API_KEY=93bd5953-5d0a-4679-a52a-87a55033238b
ENV WS_FILE_PATH=/tmp/config.yml
ENV WS_PORT=8181
ENV ZAP_PORT=8180

# expose ZAP_PORT and PORT
EXPOSE ${ZAP_PORT} ${WS_PORT}

# set the user to root
USER root

# install curl & nodejs
RUN apt-get update &&\
    apt-get install -y curl &&\
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs

# get chrome v114.x which works with the ZAP WebDriver
RUN wget https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/google-chrome-stable_122.0.6261.69-1_amd64.deb -O /tmp/chrome.deb &&\
    apt install -y /tmp/chrome.deb &&\
    rm /tmp/chrome.deb

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