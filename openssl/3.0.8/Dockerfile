FROM alpine:v3.17
RUN apk upgrade --update-cache --available && \
    apk add openssl && \
    rm -rf /var/cache/apk/*
ENTRYPOINT [ "openssl" ]
