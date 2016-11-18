#!/bin/bash
set -x

database="Fantasy"
for i in $database
do
  echo "creating database"
  mysql -uroot -e "create database if not exists $i";
  echo "starting init database"
  mysql --protocol=socket -uroot $i < /app/init-db.sql
done;
