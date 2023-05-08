FROM debian:bullseye-slim AS build

ENV LANG="C.UTF-8"

COPY files /

RUN mkdir /java && \
    find / -iname 'jdk*.tar.gz' -exec tar xfz {} -C /java \; && \
    mv /java/* /java/jdk && \
    /java/jdk/bin/jlink \
    --add-modules java.base,java.datatransfer,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.httpserver,jdk.internal.vm.ci,jdk.jdwp.agent,jdk.jfr,jdk.jsobject,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.xml.dom,jdk.zipfs \
    --strip-java-debug-attributes \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

FROM debian:bullseye-slim

ENV JAVA_HOME="/opt/java/jre" \
    PATH="/opt/java/jre/bin:${PATH}" \
    LANG="C.UTF-8"

COPY --from=build /javaruntime $JAVA_HOME

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --no-install-recommends --yes fontconfig tini procps && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tini", "-v","-g", "--"]
