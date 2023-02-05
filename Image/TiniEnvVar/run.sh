#!/bin/bash

docker build -t check-env-var:01 .

docker run --rm \
  -e "VAR1=123" \
  -e "VAR2=qaz" \
  -e "VAR-1=456" \
  -e "VAR-2=wsx" \
  -e "VAR.1=789" \
  -e "VAR.2=edc" \
  -e "VAR_1=000" \
  -e "VAR_2=rfv" \
  -e "TOP_OPTS=-b" \
  --user 1000:1000 \
  --read-only \
  check-env-var:01

docker rmi check-env-var:01
