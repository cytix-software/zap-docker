#!/bin/bash

# start the server
cd /srv/ymlapi && npm run serve &

# define the log file location
LOG_FILE=/root/.ZAP/zap.log

# remove a log file if it is found
if [ -f "$LOG_FILE" ]; then
  rm -rf $LOG_FILE
fi

# cd to zap
cd /zap && zap.sh -daemon -host 0.0.0.0 -Xmx2048m -port ${ZAP_PORT} -config api.addrs.addr.name=.* -config selenium.chromeArgs.arg.argument=--disable-dev-shm-usage -config api.addrs.addr.regex=true -config selenium.chromeArgs.arg.argument=--no-sandbox -config rules.domxss.browserid=chrome-headless -config api.key=${API_KEY} &

# get the zap pid from the previous process
ZAP_PID=$!

# wait for ZAP log file before continuing
while [ ! -f "$LOG_FILE" ]; do
  echo "Waiting for ZAP log file to be present."
  sleep 1
done

# only terminate the zap process if auth test fails
while true; do
  if grep -q "failed: Auth Test" /root/.ZAP/zap.log; then
    kill $ZAP_PID
    exit 1
  fi
  sleep 5
done

# wait until any process terminates
wait -n

# exit with the status of the process that terminated first
exit $?