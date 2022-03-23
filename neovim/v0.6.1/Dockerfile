FROM alpine:latest
LABEL maintainer="Kien Nguyen-Tuan <kiennt2609@gmail.com>"

ENV VERSION v0.6.1

RUN apk add --no-cache build-base \
    cmake \
    automake \
    git \
    autoconf \
    libtool \
    pkgconf \
    coreutils \
    curl \
    unzip \
    gettext-tiny-dev
RUN git clone https://github.com/neovim/neovim.git && \
    cd neovim && \
    git checkout $VERSION && \
    make && \
    make install && \
    cd ../ && rm -rf neovim
RUN adduser --disabled-password --gecos '' vimuser && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
USER vimuser
CMD nvim
