#!/bin/bash
DECODEARGS="--max-segment 400 --spat 9 53 10 54 --threads 2"

DATASOURCE="PG:dbname=${PGDATABASE} host=${PGHOST} user=${PGUSER} port=${PGPORT}"
DECODE="ogr-decode ${DECODEARGS}"

WORK="$HOME/tg/work"

cat "$(dirname $0)/decode.dat" | while read line; do
  if [[ "$line" == \#* ]]; then
    continue
  fi
  IFS=';' read -r -a array <<< "$line"
  WORKDIR="${WORK}/${array[1]}" 
  LAYERNAME="${array[2]}" 
  EXTRAS=${array[3]} 
  AREATYPE="${array[0]}" 

  mkdir -p "${WORKDIR}"
  # skip 
  if [ -a "${WORKDIR}/${LAYERNAME}" -a "${WORKDIR}/${LAYERNAME}" -nt "$(dirname $0)/decode.dat" ]; then
    echo "Skipping existing ${LAYERNAME}"
    continue
  fi

  echo "Processing ${LAYERNAME}"
  ${DECODE} --area-type "${AREATYPE}" ${EXTRAS} "${WORKDIR}" "${DATASOURCE}" "${LAYERNAME}" || exit $?
  date > "${WORKDIR}/${LAYERNAME}" 
done
