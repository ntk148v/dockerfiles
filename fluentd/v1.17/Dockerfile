FROM fluent/fluentd:v1.17-1
LABEL maintainer="Kien Nguyen-Tuan <kiennt2609@gmail.com>"
# Use root account to use apk
USER root

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish
RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-elasticsearch \
 && sudo gem install fluent-plugin-grok-parser \
 && sudo gem install fluent-plugin-prometheus \
 && sudo gem install fluent-plugin-rewrite-tag-filter \
 && sudo gem install fluent-plugin-record-modifier \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

RUN addgroup -S td-agent && adduser -S -G td-agent td-agent
USER td-agent
