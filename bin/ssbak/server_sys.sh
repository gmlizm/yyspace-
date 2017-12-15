#!/bin/sh

JAVA_HOME=$IPHARM_HOME/tool/jdk1.8.0_112
JRE_HOME=$JAVA_HOME/jre

# check env: IPHARM_HOME
if [[ -z $IPHARM_HOME ]] || [[ ! -x $IPHARM_HOME ]]; then
  IPHARM_HOME=$(cd `dirname $0`/..; pwd)
fi

#SS_FILE=$0 && SYS_SIGN=${SS_FILE%.sh} && SYS_SIGN=${SYS_SIGN#*\_}
#APP_NAME="$2"
#SERVICE_NAME=${SYS_SIGN}_$APP_NAME
########################################
SYS_SIGN=sys
APP_NAME=syscenter
SERVICE_NAME=systemcenter-provider
########################################
SERVICE_DIR=$IPHARM_HOME/$SYS_SIGN && WORK_DIR=$SERVICE_DIR/work
TAR_NAME=$(ls $SERVICE_DIR/ext|sort -r|grep -m 1 -E "$SERVICE_NAME-[0-9\.]+(-.*)?\.tar\.gz"|cut -f 1)
JAR_NAME=${TAR_NAME%.tar.gz}\.jar
PID=$SERVICE_NAME\.pid

## properties name
case $2 in
    gy|dp|report|upload|all)
        DUBBO_PROPERTIES_FILE="${SERVICE_NAME}.properties"
	;;
    systemcenter)
        DUBBO_PROPERTIES_FILE="systemcenter.properties"
	;;
    *)
	echo -e "error! only accept params [start|stop|restart gy|dp|report|upload|all|systemcenter]. eg:\n  #> server_xxx.sh start yyy"
        exit 0
	;;
esac

# TODO for hook, use -agentpath instead
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SERVICE_DIR/bin/hook

# parse used config
SERVER_PORT=`sed '/dubbo.protocol.port/!d;s/.*=//' $SERVICE_DIR/etc/$DUBBO_PROPERTIES_FILE | tr -d '\r'`
JVM_OPTION=`sed '/JVM_OPTION/!d;s/=//;s/JVM_OPTION//' $SERVICE_DIR/etc/$DUBBO_PROPERTIES_FILE | tr -d '\r'`
if [ -z "$JVM_OPTION" ];then
    JVM_OPTION="-server -Xms256m -Xmx2g -XX:+AggressiveOpts -XX:+UseParallelGC -XX:NewSize=128m -XX:PermSize=256M"
fi

# execute command
case "$1" in
    start)
        if [ -z "$SERVER_PORT" ]; then echo "ERROR: CONFIG dubbo.protocol.port not define!" && exit 0; fi
        _XCOUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
        if [ $_XCOUNT -gt 0 ]; then echo "ERROR: SERVICE $SERVICE_NAME on port $SERVER_PORT already used!" && exit 0; fi
        if [ ! -f $SERVICE_DIR/ext/$TAR_NAME ]; then echo "ERROR: $SERVICE_DIR/ext/$TAR_NAME not exists!" && exit 0; fi

        # process tar.gz package
        rm -rf $WORK_DIR/$SERVICE_NAME && mkdir -p $WORK_DIR
        tar -C $WORK_DIR -xzf $SERVICE_DIR/ext/$TAR_NAME
        #start
        APP_OPTS="-Dipharm.workdir=${IPHARM_HOME} -Dipharm.app.name=${APP_NAME} -Dipharm.app.props=${SERVICE_NAME}"
        $JRE_HOME/bin/java $JVM_OPTION $APP_OPTS -cp $SERVICE_DIR/etc:$WORK_DIR/$SERVICE_NAME/lib/*.jar:$WORK_DIR/$SERVICE_NAME/$JAR_NAME com.alibaba.dubbo.container.Main 2>&1 &

        mkdir -p $SERVICE_DIR/bin/pid
        echo $! > $SERVICE_DIR/bin/pid/$PID
        ;;

    stop)
        if [ -f $SERVICE_DIR/bin/pid/$PID ]; then _XPID=`cat $SERVICE_DIR/bin/pid/$PID`; fi
        if [ -z "$_XPID" ]; then
            _XPIDS=`ps -ef | grep java | grep "$SERVICE_DIR/etc" |awk '{print $2}'`
            for _YPID in $_XPIDS ; do
                _XCOUNT=`netstat -ltp|grep $_YPID|grep $SERVER_PORT|wc -l`
                if [ $_XCOUNT -gt 0 ]; then
                    _XPID=$_YPID
                    break
                fi
            done
            if [ -z "$_XPID" ]; then echo 'ERROR: service $SERVICE_NAME on port $SERVER_PORT not started!' && exit 0; fi
        fi

        echo -e "Stopping the $SERVER_NAME ...\c"
        kill $_XPID > /dev/null 2>&1
        PID_EXIST=`ps -fp $_XPID | grep java`
        while [ -n "$PID_EXIST" ]; do    
            echo -e ".\c" && sleep 1
            PID_EXIST=`ps -fp $_XPID | grep java`
        done
        rm -rf $SERVICE_DIR/bin/pid/$PID
        echo "OK! PID: $_XPID"
        ;;

    restart)
        $0 stop $2
        sleep 2
        $0 start $2
        ;;
    *)
        echo "ERROR: first param only accept start|stop|restart"
        ;;

esac
exit 0

