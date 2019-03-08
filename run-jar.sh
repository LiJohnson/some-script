#!/bin/bash
# by lcs
# create 2018-03-29
#
# update 2019-01-31 by lcs

JAR_FILE=`ls $1`
JAR_FILE_NAME=`basename $JAR_FILE`
LOG_FILE=${JAR_FILE}.log
shift

function kill_pid() {
    COUNT=0
    PID=$1
    PID_EXIST=`ps -f -p ${PID} | grep java`
    echo "killing $PID ==> $PID_EXIST"
    kill ${PID}
    while [[ ${COUNT} -lt 10 ]]; do
        PID_EXIST=`ps -f -p ${PID} | grep java`
        if [[ -n "$PID_EXIST" ]]; then
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

PIDS=`ps -ef | grep java | grep -v grep | grep "$JAR_FILE" |awk '{print $2}'`

if [ -n "$PIDS" ]; then
    echo "The $JAR_FILE is running !"
    echo "PID: $PIDS"
    for PID in $PIDS ; do
        kill_pid $PID
    done
    sleep 1
fi

echo "LOG_FILE : $LOG_FILE"
nohup java -jar $JAR_FILE  $@ > $LOG_FILE 2>&1 &
#tail -f $LOG_FILE
