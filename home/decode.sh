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

DATASOURCE="PG:dbname=${PGDATABASE} host=${PGHOST} user=${PGUSER} port=${PGPORT}"

ogrdecode ()
{
  if [ ! -z "$DEBUG" ]; then
    echo ogr-decode --max-segment 400 --spat 9 53 11 54 --threads 2 --area-type "$AREATYPE" ${EXTRAS[@]} "${WORKDIR}" "${DATASOURCE}" "${LAYERNAME}"
  fi
  ogr-decode --max-segment 400 --spat 9 53 10 54 --threads 2 --area-type "$AREATYPE" "${EXTRAS[@]}" "${WORKDIR}" "${DATASOURCE}" "${LAYERNAME}"
}

WORK="${BASE}/tg/work"

cat "${INPUT}" | while read line; do
  if [[ "$line" == \#* ]]; then
    continue
  fi
  IFS=';' read -r -a array <<< "$line"
  AREATYPE="${array[0]}"
  WORKDIR="${WORK}/${array[1]}" 
  LAYERNAME="${array[2]}" 
  EXTRAS=("${array[@]:3}")

  mkdir -p "${WORKDIR}"

  # skip 
  if [ -a "${WORKDIR}/${LAYERNAME}" ]; then
    if [ -z "$FORCE" ]; then
      echo "Skipping existing ${LAYERNAME}"
      continue
    fi
  fi

  echo "Processing ${WORKDIR}/${LAYERNAME}"
  ogrdecode || exit $?
  date > "${WORKDIR}/${LAYERNAME}" 
done
