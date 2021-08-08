#!/bin/bash
# docker版 run-tomcat.sh
# by lcs
# 2021-08-08

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

context_path="/"
if [ -n "$3" ] ;then
    context_path=$3
fi

context_path=$(echo $context_path | sed 's|^/||')

app="tomcat_$app_name"

echo "app: $app"
echo "port: $port"
echo "app_path: $app_path"
echo "app_name: $app_name"
echo "context_path: $context_path"

sudo docker stop $app || echo "docker stop $app error"
sudo docker rm $app || echo "docker rm $app error"

echo "docker starting $app"

sudo docker run -d \
    --name="$app" \
    --restart=always \
    -p "${port}:8080" \
    -e CATALINA_OPTS="-Xmx500m" \
    -v "${JAR_FILE}:${JAR_FILE}" \
    -v "${app_path}:/usr/local/tomcat/webapps/${context_path}" \
    tomcat:8-jdk8