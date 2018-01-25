#!/bin/bash
DB_HOST=10.1.1.149
DB_USER=root
DB_PWD=root
SQLDIR=dbscript

mkdir -p ${SQLDIR}
mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_gy --no-data > ${SQLDIR}/create_gy.sql
sed -ri 's/AUTO_INCREMENT=[0-9]*\ //g' ${SQLDIR}/create_gy.sql

mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_dp --no-data > ${SQLDIR}/create_dp.sql
sed -ri 's/AUTO_INCREMENT=[0-9]*\ //g' ${SQLDIR}/create_dp.sql

mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_report --no-data > ${SQLDIR}/create_report.sql
sed -ri 's/AUTO_INCREMENT=[0-9]*\ //g' ${SQLDIR}/create_report.sql

mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_upload --no-data > ${SQLDIR}/create_upload.sql
sed -ri 's/AUTO_INCREMENT=[0-9]*\ //g' ${SQLDIR}/create_upload.sql


#mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_report --no-create-info --replace --tables report report_item report_item_calc report_item_relation report_script_config > ${SQLDIR}/data_report.sql

#mysqldump -h${DB_HOST} -u${DB_USER} -p${DB_PWD} ipharmacare_upload --no-create-info --replace --tables upload_dt_name upload_rule upload_ver_map > ${SQLDIR}/data_upload.sql

