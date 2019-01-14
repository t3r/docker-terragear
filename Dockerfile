#vim:set ft=dockerfile
###
# A builder image
###
FROM ubuntu:bionic AS build

RUN true && \
    apt-get update && \
    apt-get install -y \
      build-essential \
      cmake \
      libboost-dev \
      libcgal-dev libgdal-dev \
      libcurl4-openssl-dev \
      git \
      zlib1g-dev

ARG SGBRANCH=next
ARG SGURL=https://git.code.sf.net/p/flightgear/simgear
ARG TGBRANCH=next
ARG TGURL=https://git.code.sf.net/p/flightgear/terragear

RUN useradd --create-home --home-dir=/home/flightgear --shell=/bin/false flightgear
USER flightgear

WORKDIR /home/flightgear

# Build SimGear
RUN true \
    && git clone -b ${SGBRANCH} --single-branch ${SGURL} \
    && cd simgear \
    && git status && git log HEAD^..HEAD \
    && cd .. \
    && mkdir -p build/simgear \
    && cd build/simgear \
    && cmake -D CMAKE_BUILD_TYPE=Release -D "CMAKE_CXX_FLAGS=-pipe" -DSIMGEAR_HEADLESS=ON -DENABLE_TESTS=OFF -DENABLE_PKGUTIL=OFF -DENABLE_DNS=OFF -DENABLE_SIMD=OFF -DENABLE_RTI=OFF -DCMAKE_PREFIX_PATH=$HOME/dist -DCMAKE_INSTALL_PREFIX:PATH=$HOME/dist ../../simgear \
    && make -j1 install \
    && cd ../..

# Build TerraGear
RUN true \
    && git clone -b ${TGBRANCH} --single-branch ${TGURL} \
    && cd terragear \
    && git status && git log HEAD^..HEAD \
    && cd .. \
    && mkdir -p build/terragear \
    && cd build/terragear \
    && cmake -D CMAKE_BUILD_TYPE=Release -D "CMAKE_CXX_FLAGS=-pipe -std=c++11" -DCMAKE_PREFIX_PATH=$HOME/dist -D CMAKE_INSTALL_PREFIX:PATH=$HOME/dist ../../terragear  \
    && make -j1 install  \
    && cd ../..

###
# Now, build the final terragear image
##
FROM ubuntu:bionic
LABEL maintainer="Torsten Dreyer <torsten@t3r.de>"
LABEL version="1.1"
LABEL description="FlightGear TerraGear Tools"

RUN true && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      gdal-bin \
      libboost-thread1.65 \
      libmpfr6 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid 1000 flightgear && useradd --uid 1000 --gid flightgear --create-home --home-dir=/home/flightgear --shell=/bin/bash flightgear

WORKDIR /home/flightgear
COPY --from=build /home/flightgear/dist/bin/* /usr/local/bin/
COPY --from=build /home/flightgear/dist/share/TerraGear /usr/local/share/TerraGear
COPY --from=build /home/flightgear/dist/lib/* /usr/lib64/

USER flightgear
