FROM quay.io/ansible/toolset
LABEL maintainer="Kien Nguyen-Tuan <kiennt2609@gmail.com>"
RUN apt update && \
    apt -y install --no-install-recommends shellcheck ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
CMD /bin/bash
