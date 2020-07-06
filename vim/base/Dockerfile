FROM ubuntu:20.04
LABEL maintainer="Kien Nguyen-Tuan <kiennt2609@gmail.com>"
# environment variables
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends vim git fontconfig curl fonts-powerline && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --disabled-password --gecos '' vimuser && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/vimuser
ENV HOME /home/vimuser
USER vimuser
# setup vim-plug plugin manager
RUN curl -k -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
COPY .vimrc $HOME/.vimrc
CMD vim
