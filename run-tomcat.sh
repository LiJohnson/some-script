#!/bin/bash
# by lcs
# 2018-12-13
if [ x"$1" = x ] ;then
	echo "usage run-tomcat <port> <app-path>"
	exit
fi
if [ x"$2" = x ] ;then
	echo "usage run-tomcat <port> <app-path>"
	exit
fi

port=$1
app_path=$(cd $2;pwd -P)

echo $port 
echo $app_path
echo $app_name
TOMCAT_HOME=/opt/apache-tomcat-8.5.35
#JAVA_HOME=/opt/jdk1.8.0_181
APPS_PATH=$TOMCAT_HOME/apps
APP_PATH=$APPS_PATH/$port
CATALINA_PID=$APP_PATH/pid
CATALINA_OUT=$APP_PATH/catalina.out

server_xml=$APP_PATH/server.xml
work_path=$APP_PATH/work

rm -rf $work_path

if [ ! -d "$APPS_PATH" ];then
	mkdir $APPS_PATH
fi

if [ ! -d "$APP_PATH" ];then
	mkdir $APP_PATH
fi

cat $TOMCAT_HOME/server.xml.tpl > $server_xml
sed -i "s|8080|$port|g" $server_xml
sed -i 's|HOST_ATTR|workDir="'$work_path'" docBase="'$app_path'"|g' $server_xml

shift
shift


if [ -f $CATALINA_PID ];then

	pid=`cat $CATALINA_PID`

	ps -p $pid >/dev/null 2>&1

	if [ $? -eq 0 ] ; then
		echo "using shutdonw.sh to stop tomcat"
		$TOMCAT_HOME/bin/shutdown.sh -force -config $server_xml
	fi

	ps -p $pid >/dev/null 2>&1

	if [ $? -eq 0 ] ; then
		echo "using kill -9 to stop tomcat"
		sleep 3
		kill  -9 $pid
	fi

	sleep 1
	echo "."
	sleep 1
	echo "."
	sleep 1
	echo "."
	sleep 1
fi


export CATALINA_OUT
export CATALINA_PID
export JAVA_HOME
$TOMCAT_HOME/bin/catalina.sh start -config $server_xml "$@"

#tail -f $CATALINA_OUT
