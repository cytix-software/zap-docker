#!/bin/bash

# start the server
cd /srv/ymlapi && npm run serve &

# cd to zap
cd /zap && zap.sh -daemon -host 0.0.0.0 -Xmx2048m -port 8080 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=${API_KEY} &

# wait until any process terminates
wait -n

# exit with the status of the process that terminated first
exit $?