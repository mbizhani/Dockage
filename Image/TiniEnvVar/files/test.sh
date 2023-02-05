#!/bin/bash

echo "============================"
env
echo "============================"
echo "VAR1 = ${VAR1}"
echo "VAR2 = ${VAR2}"
echo "VAR-1 = ${VAR-1}"
echo "VAR-2 = ${VAR-2}"
echo "VAR.1 = ${VAR.1}"
echo "VAR.2 = ${VAR.2}"
echo "============================"
echo "-- TOP_OPTS = ${TOP_OPTS}"
top "${TOP_OPTS}"