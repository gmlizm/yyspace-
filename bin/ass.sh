#!/bin/sh

# check env: IPHARM_HOME
if [[ -z $IPHARM_HOME ]] || [[ ! -x $IPHARM_HOME ]]; then IPHARM_HOME=$(cd `dirname $0`/..; pwd); fi

# set JAVA_HOME and JRE_HOME
JAVA_HOME=$JAVA_HOME && JRE_HOME=$JAVA_HOME/jre

#set properties
case $2 in
    syscenter)
        APP_DIR="apps/sys" && SERVICE_NAME="systemcenter-provider"
        DUBBO_PROPERTIES_FILE="sys_center.properties"
	;;
    base)
        APP_DIR="apps/base" && SERVICE_NAME="knowledge"
        DUBBO_PROPERTIES_FILE="base_dubbo.properties"
	;;
    engine)
        APP_DIR="apps/engine" && SERVICE_NAME="engine-provider"
        DUBBO_PROPERTIES_FILE="engine-provider.properties"
	;;
    gy|dp|report|upload|all)
        APP_DIR="apps/med" && SERVICE_NAME="med_$2"
        DUBBO_PROPERTIES_FILE="${SERVICE_NAME}.properties"
	;;
    *)
	echo "ERROR: second param only accept [syscenter|base|engine|medall|gy|dp|report|upload]!"
        echo -e "\tfor syscenter use : \n\t\t#> $0 start sys"
        echo -e "\tfor knowledge use : \n\t\t#> $0 start base"
        echo -e "\tfor med       use : \n\t\t#> $0 start [all|gy|dp|report|upload]"
        exit 0
	;;
esac

APP_DIR=$IPHARM_HOME/$APP_DIR && APP_WORKDIR=$APP_DIR/work
TAR_NAME=$(ls $APP_DIR/ext|sort -r|grep -m 1 -E "$SERVICE_NAME-[0-9\.]+(-.*)?\.tar\.gz"|cut -f 1) && JAR_NAME=${TAR_NAME%.tar.gz}\.jar
PID_FILE=$IPHARM_HOME/bin/.tmp/${SERVICE_NAME}.pid

# parse used config
SERVER_PORT=`sed '/dubbo.protocol.port/!d;s/.*=//' $APP_DIR/etc/$DUBBO_PROPERTIES_FILE | tr -d '\r'`
JVM_OPTION=`sed '/JVM_OPTION/!d;s/=//;s/JVM_OPTION//' $APP_DIR/etc/$DUBBO_PROPERTIES_FILE | tr -d '\r'`
if [ -z "$JVM_OPTION" ];then JVM_OPTION="-server -Xms512m -Xmx2g -Xmn128m -XX:+UseParallelGC -XX:PermSize=256M"; fi
JVM_OPTION=$JVM_OPTION' -agentpath:'$IPHARM_HOME'/bin/hook/libipharmacare_hook.so'

# execute command
case "$1" in
    start)
        #################################################-knowledge
        if [ $2 == "base" ]; then
            ${JRE_HOME}/bin/java -jar -DIPHARM_HOME=${IPHARM_HOME} -Detcdir=$APP_DIR/etc -Dipharm.app.name=$2 ${APP_DIR}/knowledge-dubbo-1.2.0-SNAPSHOT.jar 2>&1; exit 0;
        fi
        #################################################-knowledge
        
        if [ -z "$SERVER_PORT" ]; then echo "ERROR: CONFIG dubbo.protocol.port not define!"; exit 0; fi
        _XCOUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
        if [ $_XCOUNT -gt 0 ]; then echo "ERROR: SERVICE $SERVICE_NAME on port $SERVER_PORT already used!"; exit 0; fi
        if [ ! -f $APP_DIR/ext/$TAR_NAME ]; then echo "ERROR: $APP_DIR/ext/$TAR_NAME not exists!"; exit 0; fi
        
        # process tar.gz package
        rm -rf $APP_WORKDIR/$SERVICE_NAME; mkdir -p $APP_WORKDIR
        tar -C $APP_WORKDIR -xzf $APP_DIR/ext/$TAR_NAME
        #start
        APP_OPTS="-DIPHARM_HOME=${IPHARM_HOME} -Dipharm.app.name=$2 -Dipharm.app.props=${SERVICE_NAME}"
        $JRE_HOME/bin/java $JVM_OPTION $APP_OPTS -cp $APP_DIR/etc:$APP_WORKDIR/$SERVICE_NAME/lib/*.jar:$APP_WORKDIR/$SERVICE_NAME/$JAR_NAME com.alibaba.dubbo.container.Main 2>&1
        
        mkdir -p ${PID_FILE%\/*}
        echo $! > $PID_FILE
        ;;

    stop)
        if [ -f $PID_FILE ]; then _XPID=`cat $PID_FILE`; fi
        if [ -z "$_XPID" ]; then
            _XPIDS=`ps -ef | grep java | grep "$APP_DIR/etc" |awk '{print $2}'`
            for _YPID in $_XPIDS ; do
                _XCOUNT=`netstat -ltp|grep $_YPID|grep $SERVER_PORT|wc -l`
                if [ $_XCOUNT -gt 0 ]; then
                    _XPID=$_YPID
                    break
                fi
            done
            if [ -z "$_XPID" ]; then echo "ERROR: service $SERVICE_NAME on port $SERVER_PORT not started!"; exit 0; fi
        fi

        echo -e "Stopping the $2 ...\c"
        kill $_XPID > /dev/null 2>&1
        PID_EXIST=`ps -fp $_XPID | grep java`
        while [ -n "$PID_EXIST" ]; do    
            echo -e ".\c" && sleep 1
            PID_EXIST=`ps -fp $_XPID | grep java`
        done
        rm -rf $PID_FILE
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

