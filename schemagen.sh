#!/bin/bash
# schemagen.sh
#
# 1. Process schema files with KASLcred
# 2. Move saidified schema files to saidified_schemas directory
# 3. Rename schema files based on

SCHEMAS_DIR=./schemas_raw
RULES_DIR=./schema_rules
RESULTS_DIR=./schemas_saidified
MAP_FILE_PATH=./schemas_raw/schema-map.json
RENAMED_DIR=./schemas_renamed

print_help() {
    echo "Usage: schemagen.sh"
}

process_schema_files() {
    ./saidify-schemas.sh

    echo "Extracting rules"
    python extract_schema_rules.py ${SCHEMAS_DIR} ${RULES_DIR}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to extract rules."
        exit 1
    fi

    # rename files
    echo "renaming schema files"
    python rename_schemas.py ${RESULTS_DIR} ${RENAMED_DIR}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to rename schema files."
        exit 1
    fi
}

main() {
    if ! command -v python > /dev/null; then
        echo "Python is not installed or not in PATH."
        exit 1
    fi

    process_schema_files
}

main "$@"
