#!/bin/bash

REMOTE_BASEDIR=/mnt/yyspace
LOCAL_BASEDIR=/data/yyspace-

echo "### END!"

echo "====copy knowledge*.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/knowledge/ext/knowledge*.tar.gz $LOCAL_BASEDIR/apps/knowledge/ext

echo "====copy systemcenter*.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/sys/ext/systemcenter*.tar.gz $LOCAL_BASEDIR/apps/sys/ext

echo "====copy engine*.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/engine/ext/engine*.tar.gz $LOCAL_BASEDIR/apps/engine/ext

echo "====copy med_all*.tar.gz"
scp yyuser1@10.1.1.186:$REMOTE_BASEDIR/med/ext/med_all*.tar.gz $LOCAL_BASEDIR/apps/med/ext

echo "### END!"
