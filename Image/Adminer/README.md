# Adminer for MySQL + Postgres + Mongo + Oracle

The official image does not support Mongo & Oracle. Then I found [dockette](https://github.com/dockette/adminer),
which helps me a lot, and my `Dockerfile` is mostly based on their `Dockerfile` for oracle. However, their
`full` image does not support oracle. So I decided to combine `Dockerfile` from their `full` and `oracle-12` folders
to create an Adminer project to support MySQL, Postgres, Mongo, and Oracle.


## Create

- Download following files from [oracle instant client for linux](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html) to `files` (besides `Dockerfile`)
  - `instantclient-basic-linux.x64-12.2.0.1.0.zip`
  - `instantclient-sdk-linux.x64-12.2.0.1.0.zip`
- `docker build -t adminer:01 .`


## Run

- `docker run -p 8080:80 adminer:01`


## Acknowledge

Thanks a lot [dockette](https://github.com/dockette/adminer) for your great help.