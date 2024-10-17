#!/bin/bash
# saidify-schemas.sh
# Process ACDC schemas in /schemas with KASLcred, calculating and adding SAIDd

function check_dependencies() {
  python check_kaslcred.py
  SUCCESS=$?
  if [ $SUCCESS == 1 ]; then
    log "${RED}kaslcred not found${EC}. Exiting."
    exit 1
  fi
}

echo "Processing schemas with KASLcred"

python -m kaslcred \
       ${SCHEMAS_DIR:-./schemas_raw} \
       ${RESULTS_DIR:-./schemas_saidified} \
       ${MAP_FILE_PATH:-${SCHEMAS_DIR:-./schemas_raw}/schema-map.json}

if [ $? -ne 0 ]; then
    echo "Error: Schema SAIDification failed."
    exit 1
fi
