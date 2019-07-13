FROM alpine:3.9

RUN adduser -g mongodb -DH -u 1000 mongodb \
    && apk --no-cache add mongodb=4.0.5-r0 \
    && mkdir -p /data/db \
    && chown -R mongodb:mongodb /data/db

VOLUME /data/db

EXPOSE 27017

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD [ "mongod" ]