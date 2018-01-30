#!/bin/bash
usage() { echo "Usage: $0 [-i<inputfile>] [-i -] [-b<basedir>] [-f] [-d]" 1>&2; exit 1; }

INPUT=""
FORCE=""
BASE="$HOME"

while getopts ":i:b:fd" o; do
  case "${o}" in
    i)
      INPUT="${OPTARG}"
      ;;
    b)
      BASE="${OPTARG}"
      ;;
    f)
      FORCE=1
      ;;
    d)
      DEBUG=1
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ "${INPUT}" != "-" -a ! -r "${INPUT}" ]; then
  echo "Can't read input: ${INPUT}"
  exit 1
fi

DECODEARGS="--max-segment 400 --spat 9 53 10 54 --threads 2"
DATASOURCE="PG:dbname=${PGDATABASE} host=${PGHOST} user=${PGUSER} port=${PGPORT}"
DECODE="ogr-decode ${DECODEARGS}"

WORK="${BASE}/tg/work"

cat "${INPUT}" | while read line; do
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
  if [ -a "${WORKDIR}/${LAYERNAME}" -a "${WORKDIR}/${LAYERNAME}" -nt "${INPUT}" ]; then
    if [ -z "$FORCE" ]; then
      echo "Skipping existing ${LAYERNAME}"
      continue
    fi
  fi

  echo "Processing ${LAYERNAME}"
  if [ ! -z "$DEBUG" ]; then
    echo ${DECODE} --area-type "${AREATYPE}" ${EXTRAS} "${WORKDIR}" "${DATASOURCE}" "${LAYERNAME}"
  fi
  ${DECODE} --area-type "${AREATYPE}" ${EXTRAS} "${WORKDIR}" "${DATASOURCE}" "${LAYERNAME}" || exit $?
  date > "${WORKDIR}/${LAYERNAME}" 
done
