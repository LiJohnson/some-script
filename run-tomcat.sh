#!/bin/bash
# by lcs
# 2018-12-13
# 2019-03-08 优化重启tomcat
# 2021-06-18 添加可选参数[context-path]

if [ x"$1" = x ] ;then
    echo "usage run-tomcat <port> <app-path> [context-path]"
    exit
fi
if [ x"$2" = x ] ;then
    echo "usage run-tomcat <port> <app-path> [context-path]"
    exit
fi

port=$1
app_path=$(cd $2;pwd -P)
app_name=$(basename $app_path)
echo $port 
echo $app_path
echo $app_name
TOMCAT_HOME=/opt/apache-tomcat-8.5.38
#JAVA_HOME=/opt/jdk1.8.0_181
APPS_PATH=$TOMCAT_HOME/apps
APP_PATH=$APPS_PATH/$port
CATALINA_PID=$APP_PATH/pid
CATALINA_OUT=$APP_PATH/catalina.out

server_xml=$APP_PATH/server-${app_name}.xml
work_path=$APP_PATH/work

rm -rf $work_path

if [ ! -d "$APPS_PATH" ];then
    mkdir $APPS_PATH
fi

if [ ! -d "$APP_PATH" ];then
    mkdir $APP_PATH
fi

context_path="/"
if [ -n "$3" ] ;then
    context_path=$3
    shift
fi

cat $TOMCAT_HOME/server.xml.tpl > $server_xml
sed -i "s|8080|$port|g" $server_xml
sed -i 's|HOST_ATTR|path="'$context_path'" workDir="'$work_path'" docBase="'$app_path'"|g' $server_xml

shift
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

PIDS=`ps -ef | grep java | grep -v grep | grep "$server_xml" |awk '{print $2}'`

if [ -n "$PIDS" ]; then
    echo "tomcat server.xml => $server_xml is running !"
    echo "PID: $PIDS"
    for PID in $PIDS ; do
       kill_pid $PID
    done
    sleep 1
fi


export CATALINA_OUT
export CATALINA_PID
export JAVA_HOME
$TOMCAT_HOME/bin/catalina.sh start -config $server_xml "$@"

#tail -f $CATALINA_OUT
