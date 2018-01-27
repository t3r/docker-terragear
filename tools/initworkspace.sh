#!/bin/bash

TGROOT=/home/flightgear/tg

test -d ${TGROOT}/data && exit 0
echo "Initializing Workspace"

for f in data output work mirrors; do
  mkdir -p ${TGROOT}/$f
done
