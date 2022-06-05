#!/bin/bash

docker exec app-registry registry garbage-collect /etc/docker/registry/config.yml
