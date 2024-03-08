# use ZAP as base image
FROM --platform=linux/amd64 softwaresecurityproject/zap-stable:2.14.0

# define ZAP api key, web server file path and web server port
ENV API_KEY=MY_SUPER_SECRET_API_KEY
ENV ZAP_PORT=8080

# expose ZAP_PORT and PORT
EXPOSE ${ZAP_PORT}

# set healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl --fail http://localhost:${ZAP_PORT} || exit 1

# set the user to root
USER root

# get chrome v114.x which works with the ZAP WebDriver
RUN apt-get update &&\
    apt-get upgrade &&\
    wget https://dl.google.com/linux/deb/pool/main/g/google-chrome-stable/google-chrome-stable_122.0.6261.69-1_amd64.deb -O /tmp/chrome.deb &&\
    apt install -y /tmp/chrome.deb &&\
    rm /tmp/chrome.deb

# copy the init.sh to root and make executable
COPY init.sh /
RUN chmod +x /init.sh

# set the user back to zap
USER zap

# run the init
CMD /init.sh