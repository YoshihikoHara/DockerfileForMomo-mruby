#
# Last Updete: 2018/11/12
#
# Author: Yoshihiko Hara
#
# Overview:
#   Create a container containing development environment of momo-mruby (mruby for GR-PEACH).
#

# Specify the image (Ubuntu 16.04) to be the base of the container.
From ubuntu:16.04

# Specify working directory (/root).
WORKDIR /root

# Update applications and others.
RUN apt-get -y update
RUN apt-get -y upgrade

# Install network tools (ip, ping, ifconfig).
RUN apt-get -y install iproute2 iputils-ping net-tools

# Install working tools (vim, wget, curl, git).
RUN apt-get -y install apt-utils
RUN apt-get -y install software-properties-common
RUN apt-get -y install vim wget curl git

# Set the root user's password (pw = root).
RUN echo 'root:root' | chpasswd

# Install sshd.
RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd

# Change the setting so that the root user can SSH login.
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Install build tools(g++、make、bison)
RUN apt-get -y install g++ make bison

# Install the library necessary for building CRuby.
RUN apt-get -y install zlib1g-dev libssl-dev libreadline-dev
RUN apt-get -y install libyaml-dev libxml2-dev libxslt-dev
RUN apt-get -y install openssl libssl-dev libbz2-dev libreadline-dev

# Install CRuby(Ruby 2.5.3).
RUN wget https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.3.tar.gz
RUN tar xvzf ruby-2.5.3.tar.gz
WORKDIR /root/ruby-2.5.3
RUN ./configure
RUN make
RUN make install
WORKDIR /root

# Install Python2.7.
RUN apt-get -y install python2.7 python-pip python-setuptools python2.7-dev

# Install Mercurial.
RUN apt-get -y install mercurial
RUN echo [ui] > /root/.hgrc
RUN echo username=username@example.com >> /root/.hgrc

# Install GNU ARM Embedded Toolchain.
RUN apt-get -y install gcc-arm-none-eabi
RUN apt-get -y install u-boot-tools
RUN apt-get -y install libboost-all-dev

# Install mbed CLI.
RUN pip install mbed-cli

# Get "momo-mruby" source code & Build.
RUN git clone https://github.com/mimaki/momo-mruby.git --recursive
WORKDIR /root/momo-mruby/mruby
RUN make
ENV PATH $PATH:/root/momo-mruby/mruby/bin
# WORKDIR /root/momo-mruby
# RUN make clean && make && make

# Specify the locale.
RUN apt-get install -y locales
RUN echo "ja_JP UTF-8" > /etc/locale.gen
RUN locale-gen
