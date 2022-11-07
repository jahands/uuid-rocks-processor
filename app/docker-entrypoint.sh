#!/bin/bash

while :
do
    # Skip sleep on first run
    if test -f /tmp/railway_not_first_run; then
      echo Sleeping for 5.75h
      sleep 5.75h # BigQuery imports every 6 hours - this gives us a little buffer (15 minutes)
    else
      touch /tmp/railway_not_first_run
    fi

    echo Processing data... \
    && date \
    && pwsh -File /home/app/sync.ps1 \
    && date \
    && echo Pinging BigQuery to update data... \
    && python /home/app/update_bigquery.py \
    && echo Sending heartbeat to BetterUptime... \
    && curl -X POST $BETTERUPTIME_URL \
    && echo Done.

    # Reset memory usage
    echo Resetting memory usage by crashing
    exit 1
done
