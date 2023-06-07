#!/bin/bash

set -o errexit

function realpath() {
  CURRENT_DIR=$(pwd)
  DIR=$(dirname "${1}")
  FILE=$(basename "${1}")
  cd "${DIR}"
  echo $(pwd)/"${FILE}"
  cd "${CURRENT_DIR}"
}

# check input parameters
if [[ "$#" -lt 2 ]]; then
  echo -e "Missing parameters.\nSee run_mg_traits.sh . . --help"
  exit
fi

# handle input fna file
INPUT_FNA=$(basename "${1}")
INPUT_DIR=$(dirname $(realpath "${1}"))
shift

OUTPUT_DIR=$(dirname $(realpath "${1}"))
OUTPUT=$(basename "${1}")
shift

# links within the container
CONTAINER_SRC_DIR=/input
CONTAINER_DST_DIR=/output

docker run \
  --volume "${INPUT_DIR}":"${CONTAINER_SRC_DIR}":rw \
  --volume "${OUTPUT_DIR}":"${CONTAINER_DST_DIR}":rw \
  --detach=false \
  --rm \
  --user $(id -u):$(id -g) \
   epereira/mg_traits:latest \
  --input_file "${CONTAINER_SRC_DIR}/${INPUT_FNA}" \
  --output_dir "${OUTPUT}" \
  $@
