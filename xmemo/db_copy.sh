#!/bin/bash

SQLDIR=dbtmp
FROM_DBHOST=111.111.111.111
FROM_DBUSER=root
FROM_DBPWD=root
TO_DBHOST=111.111.111.111
TO_DBUSER=root
TO_DBPWD=root
DBLIST="ipharmacare_gy332 ipharmacare_dp332 ipharmacare_report ipharmacare_upload ipharmacare_syscenter ipharmacare_knowledge"


mkdir -p ${SQLDIR}

function expdb(){
  if [[ -n $1 && -n $2 ]]; then
    echo "###### START: export db $1"
    mysqldump -h${FROM_DBHOST} -u${FROM_DBUSER} -p${FROM_DBPWD} $1 | gzip > ${SQLDIR}/db_$2.gz
    echo "###### OVER: export db $1"
  else
    echo "params error! PARAMS: $@"
  fi
}

function impdb(){
  if [[ -n $1 && -n $2 ]]; then
    echo "###### START: import db $1"
    mysql -h${TO_DBHOST} -u${TO_DBUSER} -p${TO_DBPWD} -e "DROP DATABASE IF EXISTS $1; CREATE DATABASE $1 DEFAULT CHARACTER SET utf8"
    gunzip < ${SQLDIR}/db_$2.gz|mysql -h ${TO_DBHOST} -u ${TO_DBUSER} -p ${TO_DBPWD} --show-warnings=false $1
    echo "###### OVER: import db $1"
  else
    echo "params error! PARAMS: $@"
  fi
}

echo "#######BEGINE EXPORT#######################################################"
for ODB in $DBLIST; do
  expdb $ODB ${ODB/[0-9]*/}
done

echo "#######BEGINE IMPORT#######################################################"
for ODB in $DBLIST; do
  #IDB=${ODB#*\_}
  impdb ${ODB/[0-9]*/} ${ODB/[0-9]*/}
done
