#!/bin/bash
# by lcs
# 2021-04-19

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

shift

app=`basename $JAR_FILE |sed 's/.jar$//'`

sudo docker stop $app || echo "docker stop $app error"
sudo docker rm $app || echo "docker rm $app error"

echo "docker starting $app"

sudo docker run -d \
    --name="$app" \
    --network=host \
    --restart=always \
    -v "${JAR_FILE}:${JAR_FILE}" \
    -v /data/logs:/data/logs \
    docker.io/arm64v8/openjdk:11.0.10 \
    java -Xmx500m -Dlog.path=/data/logs -jar $JAR_FILE $@