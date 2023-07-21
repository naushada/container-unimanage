FROM ubuntu:jammy
ENV TZ=Asia/Calcutta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN apt-get install -y --no-install-recommends \
    ca-cacert \
    cmake \
    build-essential \
    libboost-all-dev \
    libssl-dev \
    wget \
    zlib1g-dev

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install libboost-all-dev && \
    apt-get -y install libbson-dev && \
    apt-get -y install libzstd-dev && \
    apt-get -y install git

RUN git clone -b openssl-3.1.1 https://github.com/naushada/openssl.git
RUN cd openssl && \
    gunzip openssl-3.1.1.tar.gz && \
    tar -xvf openssl-3.1.1.tar && \
    cd openssl-3.1.1 && \
    ./config --prefix=/usr/local/openssl-3.1.1 && \
    make && make install


# WORKDIR /root/mongo-c
# #RUN apt-get -y install mongodb-server-core
# RUN git clone -b r1.19 https://github.com/mongodb/mongo-c-driver.git

# RUN cd mongo-c-driver
# WORKDIR /root/mongo-c/mongo-c-driver/build
# RUN cmake ..
# RUN make && make install

# WORKDIR /root/mongo-cxx
# RUN git clone -b releases/v3.6 https://github.com/mongodb/mongo-cxx-driver.git
# RUN cd mongo-cxx-driver

# WORKDIR /root/mongo-cxx/mongo-cxx-driver/build
# RUN cmake .. -DBSONCXX_POLY_USE_MNMLSTC=1 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
# RUN make && make install
# RUN ldconfig

# WORKDIR /root
# RUN git clone https://github.com/google/googletest/
# WORKDIR /root/googletest
# RUN mkdir build && cd build && cmake .. && make install
# RUN ldconfig
WORKDIR /root

# RUN git clone -b feature/x86 https://github.com/naushada/uniimage.git
RUN git clone -b uniimage https://github.com/naushada/hyd.git uniimage
RUN cd uniimage/uniimage && \
    mkdir build
WORKDIR /root/uniimage/uniimage/build
RUN cmake .. && make

#node installation
RUN apt-get -y update && \
    apt-get -y upgrade

########## installing dependencies node_module ######################
RUN apt-get -y install curl && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get -y install nodejs && \
    npm install -g @angular/cli && \
    npm install @clr/core @clr/icons @clr/angular @clr/ui @webcomponents/webcomponentsjs --save

WORKDIR /root
RUN mkdir webclient && cd webclient

WORKDIR /root/webclient
#ARG GITHUB_TOKEN
#RUN git  clone https://${GITHUB_TOKEN}@github.com/naushada/unimanage.git webui
RUN git  clone https://github.com/naushada/unimanage.git webui
RUN cd webui
WORKDIR /root/webclient/webui/src

RUN npm install
#RUN npm update

##### Compile the Angular webgui #################

WORKDIR /root/webclient/webui

RUN ng build --configuration production --aot --base-href /webui/

RUN cd /opt && \
    mkdir xAPP && \
    cd xAPP && \
    mkdir webgui && \
    cd webgui
WORKDIR /opt/xAPP/webgui
RUN cp -r /root/webclient/webui/dist/swi .

WORKDIR /opt/xAPP
RUN mkdir uniimage && \
    cd uniimage
WORKDIR /opt/xAPP/uniimage

# copy from previoud build stage
RUN cp /root/uniimage/uniimage/build/uniimage .

# CMD_ARGS --role server --server-ip <ip-address> --server-port <server-port> --web-port <web-port> --protocol tcp
ENV ARGS="--role server --server-port 58989  --protocol tcp"
ENV PORT=58080
CMD "/opt/xAPP/uniimage/uniimage" --web-port ${PORT} ${ARGS}
