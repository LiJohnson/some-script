#!/bin/bash
# by lcs
# create 2018-03-29
#
# update 2019-01-31 by lcs
# update 2019-06-04 by lcs
# update 2019-07-24 by lcs
# update 2019-08-24 by lcs
# update 2020-03-25 by lcs

if [ -z "$1" ];then
    echo "missing jar file"
    exit 1
fi

if [ ! -f "$1" ];then
    echo "unknown jar file : $1"
    exit 1
fi

JAR_PATH=$(cd "$(dirname $1)";pwd -P)
JAR_FILE_NAME=`basename $1`
JAR_FILE="$JAR_PATH/$JAR_FILE_NAME"

if [ "$LOG_FILE" = "" ]
then
    LOG_FILE=${JAR_FILE}.log
fi
shift

function kill_pid() {
    COUNT=0
    PID=$1
    PID_EXIST=`ps -f -p ${PID} | grep java`
    echo "killing $PID ==> $PID_EXIST"
    kill ${PID}
    while [[ ${COUNT} -lt 10 ]]; do
        PID_EXIST=`ps -f -p ${PID} | grep java`
        if [[ -z "$PID_EXIST" ]]; then
            echo ""
            return
        fi
        echo -e ".\c"
        sleep 1
        COUNT=$((COUNT+1))
    done
    echo "\n kill -9 $PID"
    kill -9 ${PID}
}

run_jar=`echo  "$JAR_FILE $@" | sed 's/ $//g'`

PIDS=`ps -ef | grep java | grep -v grep | grep "$run_jar" |awk '{print $2}'`

if [ -n "$PIDS" ]; then
    echo "The $JAR_FILE is running !"
    echo "PID: $PIDS"
    for PID in $PIDS ; do
        kill_pid $PID
    done
    sleep 1
fi

echo "LOG_FILE : $LOG_FILE"
nohup java -jar $run_jar > $LOG_FILE 2>&1 &
#tail -f $LOG_FILE
