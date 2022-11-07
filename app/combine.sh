#!/bin/bash
uuids="/tmp/data/r2/uuids"
uuidsAllCsv="/tmp/data/uuids-all.csv"

# WARNING: This will not work on files with spaces!!
csvstack $(find $uuids -type f -name '*.csv') > $uuidsAllCsv
