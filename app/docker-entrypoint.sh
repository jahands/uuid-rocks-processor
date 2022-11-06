#!/bin/bash
while :
do
    echo Processing data... \
    && date \
    && pwsh -File $HOME/sync.ps1 \
    && date \
    && echo Sending heartbeat to BetterUptime... \
    && curl -X POST $BETTERUPTIME_URL
    sleep 5.75h # BigQuery imports every 6 hours - this gives us a little buffer (15 minutes)
done
