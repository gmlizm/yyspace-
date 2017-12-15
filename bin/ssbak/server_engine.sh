#!/bin/sh

JAVA_HOME=$IPHARM_HOME/tool/jdk1.8.0_112
JRE_HOME=$JAVA_HOME/jre

# check env: IPHARM_HOME
if [[ -z $IPHARM_HOME ]] || [[ ! -x $IPHARM_HOME ]]; then
  IPHARM_HOME=$(cd `dirname $0`/..; pwd)
fi

SS_FILE=$0 && SYS_SIGN=${SS_FILE%.sh} && SYS_SIGN=${SYS_SIGN#*\_}
APP_NAME=engine
SERVICE_NAME=engine-provider
SERVICE_DIR=$IPHARM_HOME/$SYS_SIGN && WORK_DIR=$SERVICE_DIR/work
TAR_NAME=$(ls $SERVICE_DIR/ext|sort -r|grep -m 1 -E "$SERVICE_NAME-[0-9\.]+(-.*)?\.tar\.gz"|cut -f 1)
JAR_NAME=${TAR_NAME%.tar.gz}\.jar
PID=$SERVICE_NAME\.pid

## properties name
DUBBO_PROPERTIES_FILE="${SERVICE_NAME}.properties"

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
        if [ -n "$SERVER_PORT" ]; then
          SERVER_PORT_COUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
          if [ $SERVER_PORT_COUNT -gt 0 ]; then
            echo "ERROR: The $APP_NAME port $SERVER_PORT already used!"
            exit 1
          fi
        fi
        # process tar.gz package
        if [ ! -f $SERVICE_DIR/ext/$TAR_NAME ]; then
           echo "ERROR: $SERVICE_DIR/ext/$TAR_NAME not exists!"
	   exit 0;
        fi

        rm -rf $WORK_DIR/$SERVICE_NAME && mkdir -p $WORK_DIR
        tar -C $WORK_DIR -xzf $SERVICE_DIR/ext/$TAR_NAME
        #start
        APP_OPTS="-Dipharm.workdir=${IPHARM_HOME} -Dipharm.app.name=${APP_NAME} -Dipharm.app.props=${SERVICE_NAME}"
        $JRE_HOME/bin/java $JVM_OPTION $APP_OPTS -cp $SERVICE_DIR/etc:$WORK_DIR/$SERVICE_NAME/lib/*.jar:$WORK_DIR/$SERVICE_NAME/$JAR_NAME com.alibaba.dubbo.container.Main 2>&1 &

        mkdir -p $SERVICE_DIR/bin/pid
        echo $! > $SERVICE_DIR/bin/pid/$PID
        ;;

    stop)
        PIDS=`ps -ef | grep java | grep "$SERVICE_DIR/etc" |awk '{print $2}'`
        if [ -z "$PIDS" ]; then
            echo "ERROR: The $SERVER_NAME does not started!"
            exit 1
        fi
        echo -e "Stopping the $SERVER_NAME ...\c"
        for PID in $PIDS ; do
            kill $PID > /dev/null 2>&1
        done

        _XCOUNT=0
        while [ $_XCOUNT -lt 1 ]; do    
            echo -e ".\c"
            sleep 1
            _XCOUNT=1
            for PID in $PIDS ; do
                PID_EXIST=`ps -f -p $PID | grep java`
                if [ -n "$PID_EXIST" ]; then
                    _XCOUNT=0
                   break
                fi
            done
        done

        echo "OK!"
        echo "PID: $PIDS"
        ;;

    restart)
        $0 stop 
        sleep 2
        $0 start 
        ;;
    *)
        echo "ERROR: first param only accept start|stop|restart"
        ;;

esac
exit 0
