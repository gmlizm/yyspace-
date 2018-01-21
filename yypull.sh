#!/bin/bash

REMOTE_HOST=10.1.1.134
REMOTE_USER=root
REMOTE_BASEDIR=/mnt/yyspace
LOCAL_BASEDIR=/data/yyspace-


echo "### START!"

echo "====copy knowledge*.tar.gz"
scp $REMOTE_USER@${REMOTE_HOST}:$REMOTE_BASEDIR/knowledge/ext/knowledge*.tar.gz $LOCAL_BASEDIR/knowledge/ext

echo "====copy systemcenter*.tar.gz"
scp $REMOTE_USER@${REMOTE_HOST}:$REMOTE_BASEDIR/sys/ext/systemcenter*.tar.gz $LOCAL_BASEDIR/apps/sys/ext

echo "====copy engine*.tar.gz"
scp $REMOTE_USER@${REMOTE_HOST}:$REMOTE_BASEDIR/engine/ext/engine*.tar.gz $LOCAL_BASEDIR/apps/engine/ext

echo "====copy med_all*.tar.gz"
scp $REMOTE_USER@${REMOTE_HOST}:$REMOTE_BASEDIR/med/ext/med_all*.tar.gz $LOCAL_BASEDIR/apps/med/ext

echo "### END!"
