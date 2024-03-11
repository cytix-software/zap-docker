#!/bin/bash

# define the log file location
LOG_FILE=$(find / -type f -name "zap.log" 2>/dev/null)

# remove a log file if it is found
if [ -f "$LOG_FILE" ]; then
  rm -rf $LOG_FILE
fi

# cd to zap
cd /zap && zap.sh \
  -daemon \
  -nostdout \
  -host 0.0.0.0 \
  -Xmx2048m \
  -port ${ZAP_PORT} \
  -config api.addrs.addr.name=.* \
  -config selenium.chromeArgs.arg.argument=--disable-dev-shm-usage \
  -config api.addrs.addr.regex=true \
  -config selenium.chromeArgs.arg.argument=--no-sandbox \
  -config rules.domxss.browserid=chrome-headless \
  -config api.key=${API_KEY} \
  -config api.filexfer=true \
  -config api.xferdir=/tmp/zap &

# get the zap pid from the previous process
ZAP_PID=$!

# wait for ZAP log file before continuing
while [ ! -f "$LOG_FILE" ]; do
  echo "Waiting for ZAP log file to be present."
  LOG_FILE=$(find / -type f -name "zap.log" 2>/dev/null)
  sleep 1
done

# echo any errors to the console
tail -F $LOG_FILE | grep --line-buffered -E "ERROR|Job spider|Job activeScan|start host http" &

# wait for zap to be online
while ! curl -sf -o /dev/null http://127.0.0.1:${ZAP_PORT}; do
  echo "Waiting for ZAP server to come online - (retry in 5 seconds)"
  sleep 5
done

# echo online and server URL to console
echo "ZAP Server is online - http://127.0.0.1:${ZAP_PORT}"

# wait until any process terminates
wait -n

# exit with the status of the process that terminated first
exit $?