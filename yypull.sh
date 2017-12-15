#!/bin/bash

REMOTE_BASEDIR=/mnt/yyspace
LOCAL_BASEDIR=/opt/yyspace

echo "###copy tar.gz"

echo "==copy to 10.1.1.91"
echo "====copy knowledge-dubbo-1.2.0-SNAPSHOT.jar"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/apps/base/knowledge-dubbo-1.2.0-SNAPSHOT.jar $LOCAL_BASEDIR/apps/base

echo "====copy systemcenter-provider-1.0-SNAPSHOT.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/apps/sys/ext/systemcenter-provider-1.0-SNAPSHOT.tar.gz $LOCAL_BASEDIR/apps/sys/ext

echo "====copy engine-yb-provider-1.2.0-SNAPSHOT.jar"
scp yyuser1@10.1.1.186:/mnt/knowledge/engine_dubbo/engine-provider-1.2.0-SNAPSHOT.tar.gz $LOCAL_BASEDIR/apps/engine/ext

echo "====copy med_all-3.4-SNAPSHOT.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/apps/med/ext/med_all-3.4-SNAPSHOT.tar.gz $LOCAL_BASEDIR/apps/med/ext

echo "### END!"
