#!/bin/bash

echo '*****************************'
echo '******** Start SOCKS ********'
echo '*****************************'

sshpass -p "${SSH_PASS}" ssh -g -D 5511 -C -N -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST}