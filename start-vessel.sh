#!/bin/bash
# start-vessel.sh

# Argument defaults
STARTUP="true"
TLS_ENABLED="false"
SERVER_NAME="vessel.tetraveda.com"

# Set variables
IMAGE_NAME="tetraveda/vessel"
CONTAINER_NAME="vessel"

# Path to the directory containing TLS certificates
CERTS_DIR="${TETRAVEDA_HOME}/tls/certs"

print_help() {
    echo "Usage: start-vessel.sh [--startup true/false] [--tls-enabled true/false]"
}

# Function to process command-line arguments
process_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --startup) STARTUP="$2"; shift ;;
            --tls-enabled) TLS_ENABLED="$2"; shift ;;
            --server-name) SERVER_NAME="$2"; shift ;;
            *) echo "Unknown parameter passed: $1"; print_help; exit 1 ;;
        esac
        shift
    done
}

container_exists() {
    docker inspect "$1" > /dev/null 2>&1
}

build_docker_image() {
    # Build the Docker image
    docker build -t $IMAGE_NAME .
    if [ $? -ne 0 ]; then
        echo "Docker build failed."
        exit 1
    fi
}

stop_docker_container() {
    if container_exists "$CONTAINER_NAME"; then
        echo "Stopping $CONTAINER_NAME"
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    fi
}

run_docker_container() {
    # Run the Docker container

    if [ "$TLS_ENABLED" = "true" ]; then
        echo "Starting $CONTAINER_NAME with TLS enabled"
        docker run -d --name $CONTAINER_NAME \
               -p 7723:443 \
               -e SERVER_NAME=$SERVER_NAME \
               -e TLS_ENABLED=$TLS_ENABLED \
               -v "$CERTS_DIR/tls.combined-chain:/etc/nginx/tls.combined-chain:ro" \
               -v "$CERTS_DIR/tls.key:/etc/nginx/tls.key:ro" \
               $IMAGE_NAME
    else
        echo "Starting $CONTAINER_NAME without TLS"
        docker run -d --name $CONTAINER_NAME \
               -e SERVER_NAME=$SERVER_NAME \
               -e TLS_ENABLED=$TLS_ENABLED \
               -p 7723:80 \
               $IMAGE_NAME
    fi

    echo "Docker container $CONTAINER_NAME is running."
}


main() {
    if [ ! -d "${TETRAVEDA_HOME}" ]; then
        echo "TETRAVEDA_HOME not set. Set to continue."
        exit 1
    fi

    if ! command -v docker > /dev/null; then
        echo "Docker is not installed or not in PATH."
        exit 1
    fi

    if ! command -v python > /dev/null; then
        echo "Python is not installed or not in PATH."
        exit 1
    fi

    process_args "$@"

    build_docker_image

    if [ $STARTUP = "true" ]; then
        echo "CERTS_DIR is $CERTS_DIR"
        stop_docker_container
        run_docker_container
    else
        stop_docker_container
        echo "Not starting Vessel"
    fi

}

main "$@"
