#!/bin/bash
#
# @description
# Script used as launcher
# @author bwnyasse
##

set -e

################
## FLAG VAR  ##
###############
FLAGS="e:d:ih"

#Flag e for export
FLAG_E=false

#Flag i for import
FLAG_I=false

#Flag d for dump
FLAG_D=false

#Flag r for restore
FLAG_R=false

################
## GLOBAL VAR ##
###############
REQUIRED_ENV_VAR=( MONGO_HOST MONGO_PORT )
REQUIRED_ENV_VAR_FOR_E=( MONGO_DB_NAME MONGO_COLLECTION_NAME MONGO_BACKUP_FILENAME)
REQUIRED_ENV_VAR_FOR_I=( MONGO_DB_NAME MONGO_COLLECTION_NAME )
REQUIRED_ENV_VAR_FOR_D=( MONGO_BACKUP_FILENAME )
REQUIRED_ENV_VAR_FOR_CRON=( CRON_SCHEDULE )

IS_NO_CRON=false
IS_CRON=false

##############################
## FUNCTIONS DECLARATION  ###
#############################

usage() {
	cat <<-EOF

  Script used to perform operation on mongoDB instance

	OPTIONS:
	========
  -e	  perform data export as JSON
  -i	  perform data import of JSON
  -d	  perform data dump
  -r	  perform data restore
  -h	  show this help

	EOF
}


usageCronFeature() {
	cat <<-EOF

  Operation with available options

	OPTIONS:
	========
no-cron   Direct export without cron
cron      Export with cron
	EOF
}


function launchImport() {
    echo "Import will be configured and starting ..."
    /bin/bash ./import.sh
}

function launchExport() {
    #CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

    echo "Export will be configured and starting ..."

    if $IS_NO_CRON; then
        /bin/bash ./export.sh
    elif $IS_CRON; then
        checkEnvVar REQUIRED_ENV_VAR_FOR_CRON[@]

        LOGFIFO='/var/log/cron.fifo'
        if [[ ! -e "$LOGFIFO" ]]; then
            mkfifo "$LOGFIFO"
        fi
            CRON_ENV="MONGO_HOST='$MONGO_HOST'"
            CRON_ENV="$CRON_ENV\nMONGO_PORT='$MONGO_PORT'"
            CRON_ENV="$CRON_ENV\nMONGO_BACKUP_FILENAME='$MONGO_BACKUP_FILENAME'"
            CRON_ENV="$CRON_ENV\nMONGO_DB_NAME='$MONGO_DB_NAME'"
            CRON_ENV="$CRON_ENV\nMONGO_COLLECTION_NAME='$MONGO_COLLECTION_NAME'"
        echo -e "$CRON_ENV\n$CRON_SCHEDULE /export.sh > $LOGFIFO 2>&1" | crontab -
        crontab -l
        cron
        tail -f "$LOGFIFO"
    fi
}

function launchDump() {
    #CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

    echo "Dump will be configured and starting ..."

    if $IS_NO_CRON; then
        /bin/bash ./dump.sh
    elif $IS_CRON; then
        checkEnvVar REQUIRED_ENV_VAR_FOR_CRON[@]

        LOGFIFO='/var/log/cron.fifo'
        if [[ ! -e "$LOGFIFO" ]]; then
            mkfifo "$LOGFIFO"
        fi

        CRON_ENV="MONGO_HOST='$MONGO_HOST'"
        CRON_ENV="$CRON_ENV\nMONGO_PORT='$MONGO_PORT'"
        CRON_ENV="$CRON_ENV\nMONGO_BACKUP_FILENAME='$MONGO_BACKUP_FILENAME'"
        echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
        crontab -l
        cron
        tail -f "$LOGFIFO"
    fi
}

function launchRestore() {
  echo "Restore will be configured and starting ..."
  /bin/bash ./restore.sh
}

function readCronFeatureOption() {
    case $1 in
        no-cron)
            IS_NO_CRON=true
            ;;
		cron)
            IS_CRON=true
            ;;
  	    *)
            usageCronFeature
            exit 1
            ;;
    esac
}

function checkEnvVar() {
    array=("${!1}")
    for envVar in ${array[@]};
    do
        value=${!envVar}
        if   [ -z "$value" ] ; then
            echo "Error: $envVar is not present."
            exit 1;
        fi
    done
}

#############################
### Effectif Script build ###
############################

echo "Welcome to mongodb Worker !!"

checkEnvVar REQUIRED_ENV_VAR[@]

while getopts $FLAGS OPT;
do
    case $OPT in
        e)
            FLAG_E=true
            checkEnvVar REQUIRED_ENV_VAR_FOR_E[@]
            readCronFeatureOption "$OPTARG"
            ;;
        i)
            FLAG_I=true
            checkEnvVar REQUIRED_ENV_VAR_FOR_I[@]
            ;;
        d)
            FLAG_D=true
            checkEnvVar REQUIRED_ENV_VAR_FOR_D[@]
            readCronFeatureOption "$OPTARG"
            ;;
        r)
            FLAG_R=true
            checkEnvVar REQUIRED_ENV_VAR_FOR_R[@]
            ;;
        *|h)
            usage
            exit 1
            ;;
    esac
done


if [ $FLAG_I = false ] && [ $FLAG_E = false ] && [ $FLAG_D = false ] && [ $FLAG_R = false ]; then
    usage
    exit 1
fi

## Launch operations
if $FLAG_I; then
    launchImport
fi

if $FLAG_E; then
    launchExport
fi

if $FLAG_D; then
    launchDump
fi

if $FLAG_R; then
    launchRestore
fi
