#!/bin/bash
#
# @description
# Script used to perform mongorestore
# mongorestore is the native mongo tool for restore ( https://docs.mongodb.com/manual/reference/program/mongorestore/ )
#
# @author drizztguen77
##

set -e

echo "Job Restore started: $(date)"

#DATE=$(date +%Y%m%d_%H%M%S)
FILE="/data/backup/$MONGO_BACKUP_FILENAME.tar.gz"
#OUTPUT="dump/"

#tar -zzvf $FILE $OUTPUT
mongorestore --quiet --gzip --host $MONGO_HOST:$MONGO_PORT --archive=$FILE
#rm -rf $OUTPUT

echo "Job Dump finished: $(date)"
