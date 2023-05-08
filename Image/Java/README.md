# JRE (Java) Image for Running Apps

The `Dockerfile` in this directory uses `tini` application to apply graceful shutdown for its child (`java`) process.
The `build` section uses JDK's `jlink` to create a JRE with the core's modules for running applications.
In the second section, installing `fontconfig` and `tini` packages are necessary.

This image is tested with Oracle JDK 17.

```shell
git clone https://github.com/mbizhani/Dockage.git
cd Dockage/Image/Java/
# Copy Oracle 'jdk-xxx_linux-x64.tar.gz' to files directory
docker build -t java:17 .
```

Now, if you execute `docker run --rm -it java:17 ps`, the output is:

```text
[INFO  tini (1)] Spawned child process 'ps' with pid '7'
    PID TTY          TIME CMD
      1 pts/0    00:00:00 tini
      7 pts/0    00:00:00 ps
[INFO  tini (1)] Main child exited normally (with status '0')
```

As you see, due to `ENTRYPOINT`, the `tini` is the root process with PID 1.
Then `tini` spawns the next command as its child, so on SIGTERM, the `tini` process shuts down its child gracefully.

## Creating Image for Runnable JAR File

Following `Dockerfile` is an example to use this base image to run an executable JAR file:

```Dockerfile
FROM java:17

ENV JAVA_OPTS=""

COPY target/*.jar /app/app.jar

CMD ["sh", "-c", "java ${JAVA_OPTS} -Djava.security.egd=file:/dev/urandom -jar /app/app.jar"]
```

**Note:** in the above example, use `CMD` instead of `ENTRYPOINT`!

## Reference

- [Gracefully Shutting Down Applications in Docker](https://joostvdg.github.io/docker/graceful-shutdown/)