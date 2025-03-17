#!/bin/bash

LOG_FILE=$(find / -type f -name "zap.log" 2>/dev/null)

if [ -f "$LOG_FILE" ]; then
  rm -rf $LOG_FILE
fi

cd /zap/zaproxy/zap/build/distFiles/ && ./zap.sh \
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

ZAP_PID=$!


while [ ! -f "$LOG_FILE" ]; do
  echo "Waiting for ZAP log file to be present."
  LOG_FILE=$(find / -type f -name "zap.log" 2>/dev/null)
  sleep 1
done

# echo any errors to the console
tail -F $LOG_FILE | grep --line-buffered -E "ERROR|Job spider|Job activeScan|start host http" &

until curl -sf -o /dev/null http://127.0.0.1:${ZAP_PORT}; do
  echo "Waiting for ZAP server (retry in 5s)..."
  sleep 5
done

echo "ZAP Server is online - http://127.0.0.1:${ZAP_PORT}"

# Keep it running...
wait -n
exit $?
