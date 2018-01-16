#!/bin/bash

############################################################################################
### params below can modify according to your need.
FROM_DBHOST=111.111.111.111; FROM_DBUSER=root; FROM_DBPWD=root
TO_DBHOST=111.111.111.111; TO_DBUSER=root; TO_DBPWD=root
DBLIST="ipharmacare_report ipharmacare_upload"



############################################################################################
SQLDIR=dbtmp
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
    gunzip < ${SQLDIR}/db_$2.gz|mysql -h${TO_DBHOST} -u${TO_DBUSER} -p${TO_DBPWD} $1
    echo "###### OVER: import db $1"
  else
    echo "params error! PARAMS: $@"
  fi
}

function exp(){
  echo "#######BEGINE EXPORT#######################################################"
  for ODB in $1; do
    expdb $ODB ${ODB/[0-9]*/}
  done
}

function imp(){
  echo "#######BEGINE IMPORT#######################################################"
  for ODB in $1; do
    #IDB=${ODB#*\_}
    impdb ${ODB/[0-9]*/} ${ODB/[0-9]*/}
  done
}


############################################################################################
params=$DBLIST
if [[ $# -gt 1 ]]; then
  params=($*)
  params=${params[@]:1}
fi

case $1 in
  exp)
    exp $params
    ;;
  imp)
    imp $params
    ;;
  copy)
    exp $params
    imp $params
    ;;
  *)
    echo "ERROR: first param only accept [exp|imp|copy]. other param is dbnames, eg: $0 exp db1 db2 db3"
    echo "if dbnames undefined, DBLIST in the file will be used."
    echo -e "  for export use : $0 exp [dbnames]"
    echo -e "  for import use : $0 imp [dbnames]"
    echo -e "  for copy   use : $0 copy [dbnames]"
    exit 0
    ;;
esac

