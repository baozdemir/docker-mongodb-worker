#!/bin/bash
#
# @description
# Script used to perform mongodump
# mongodump is the native mongo tool for dump ( https://docs.mongodb.com/manual/reference/program/mongodump/ )
#
# @author bwnyasse
##

set -e

echo "Job Dump started: $(date)"

#DATE=$(date +%Y%m%d_%H%M%S)
FILE="/data/backup/$MONGO_BACKUP_FILENAME.tar.gz"
#OUTPUT="dump/"

rm -rf $FILE
mongodump --quiet --gzip --host $MONGO_HOST:$MONGO_PORT --archive=$FILE
#tar -zcvf $FILE $OUTPUT
#rm -rf $OUTPUT

echo "Job Dump finished: $(date)"
