FROM ubuntu:22.04
LABEL maintainer="Kien Nguyen-Tuan <kienn2609@gmail.com>"
ARG PROMTOOL_VERSION=2.52.0
ARG AMTOOL_VERSION=0.27.0
WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y wget
RUN wget -qO- "https://github.com/prometheus/alertmanager/releases/download/v${AMTOOL_VERSION}/alertmanager-${AMTOOL_VERSION}.linux-amd64.tar.gz" \
    | tar xvzf - "alertmanager-${AMTOOL_VERSION}.linux-amd64"/amtool --strip-components=1 && \
    wget -qO- "https://github.com/prometheus/prometheus/releases/download/v${PROMTOOL_VERSION}/prometheus-${PROMTOOL_VERSION}.linux-amd64.tar.gz" \
    | tar xvzf - "prometheus-${PROMTOOL_VERSION}.linux-amd64"/promtool --strip-components=1


FROM alpine:3.19
COPY --from=0 /tmp/promtool /tmp/amtool /bin/
CMD ["/bin/sh"]
