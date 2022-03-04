FROM ubuntu:20.04
LABEL maintainer="Kien Nguyen-Tuan <kiennt2609@gmail.com>"
# environment variables
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends vim=2:8.1.2269-1ubuntu5 git fontconfig curl fonts-powerline ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --disabled-password --gecos '' vimuser && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/vimuser
ENV HOME /home/vimuser
COPY .vimrc $HOME/.vimrc
RUN chown vimuser:vimuser $HOME/.vimrc
USER vimuser
# setup vim-plug plugin manager
RUN curl -k -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
CMD vim
