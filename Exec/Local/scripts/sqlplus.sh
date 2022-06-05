#!/bin/bash

docker exec -it app-oracle bash -c "source /home/oracle/.bashrc; sqlplus '/ as sysdba'"
