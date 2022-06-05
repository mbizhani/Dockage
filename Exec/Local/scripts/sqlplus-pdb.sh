#!/bin/bash

docker exec -it app-oracle bash -c "source /home/oracle/.bashrc; sqlplus sys/Oradoc_db1@ORCLPDB1 as sysdba"
