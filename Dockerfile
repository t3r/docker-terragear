#vim:set ft=dockerfile
###
# A builder image
###
FROM opensuse:latest AS build
LABEL maintainer="Torsten Dreyer <torsten@t3r.de>"
LABEL version="1.0"
LABEL description="FlightGear Scenery Toolbox"

RUN zypper in -y \
  boost-devel \
  cgal-devel \
  cmake \
  gcc-c++ \
  cgal-devel \
  gdal-devel \
  git \
  libcurl-devel \
  libtiff-devel \
  zlib-devel

RUN useradd --create-home --home-dir=/home/flightgear --shell=/bin/false flightgear
USER flightgear

# Build SimGear
WORKDIR /home/flightgear
RUN true \
    && mkdir -p build/simgear \
    && git clone https://git.code.sf.net/p/flightgear/simgear \
    && pushd build/simgear \
    && cmake -D CMAKE_BUILD_TYPE=Release -DSIMGEAR_HEADLESS=ON -DENABLE_TESTS=OFF -DENABLE_PKGUTIL=OFF -DENABLE_DNS=OFF -DENABLE_SIMD=OFF -DENABLE_RTI=OFF -DCMAKE_PREFIX_PATH=$HOME/dist -DCMAKE_INSTALL_PREFIX:PATH=$HOME/dist ../../simgear \
    && make -j4 install \
    && popd

# Build TerraGear
COPY patches /home/flightgear/patches/
RUN true \
    && git clone https://git.code.sf.net/p/flightgear/terragear \
    && pushd terragear \
    && git checkout scenery/ws2.0 \
    && git config user.email "noreply@flightgear.org" \
    && git config user.name "docker bot" \
    && for f in ../patches/*; do git am < $f; done \
    && popd \
    && mkdir -p build/terragear \
    && pushd build/terragear \
    && cmake -D CMAKE_BUILD_TYPE=Release -D "CMAKE_CXX_FLAGS=-pipe -std=c++11 -fPIC" -DCMAKE_PREFIX_PATH=$HOME/dist -D CMAKE_INSTALL_PREFIX:PATH=$HOME/dist ../../terragear  \
    && make -j4 install \
    && popd

###
# Now, build the final terragear image
##
FROM opensuse:latest
LABEL maintainer="Torsten Dreyer <torsten@t3r.de>"
LABEL version="1.0"
LABEL description="FlightGear Scenery Toolbox"

RUN zypper in -y \
  libboost_thread1_54_0 \
  libgdal20 \
  libmpfr4 \
  python

RUN useradd --create-home --home-dir=/home/flightgear --shell=/bin/false flightgear
USER flightgear

WORKDIR /home/flightgear
COPY --from=build /home/flightgear/dist/bin/* /usr/local/bin/
COPY --from=build /home/flightgear/dist/lib64/* /usr/local/lib64/

COPY tools/* /usr/local/bin/
