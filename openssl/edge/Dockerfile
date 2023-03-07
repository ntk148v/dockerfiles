FROM alpine:edge
RUN apk upgrade --update-cache --available && \
    apk add openssl && \
    rm -rf /var/cache/apk/*
ENTRYPOINT [ "openssl" ]
