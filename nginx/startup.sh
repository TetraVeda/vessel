#!/bin/sh
# startup.sh
# NGINX Startup script for Vessel
# Generates correct configuration script based on whether TLS is enabled or not
# Make sure to set SERVER_NAME correctly

export SERVER_NAME=${SERVER_NAME:-"vessel.tetraveda.com"}
echo "SERVER_NAME set to ${SERVER_NAME}"
export TEMPLATE_DIR="/etc/nginx/tpl"

TLS_ENABLED=${TLS_ENABLED:-"false"}
NGINX_CONF_DIR="/etc/nginx/conf.d"

# Verify templates exist
if [ ! -f "${TEMPLATE_DIR}/https.tpl.conf" ] || [ ! -f "${TEMPLATE_DIR}/http.tpl.conf" ]; then
    echo "NGINX configuration templates not found in ${TEMPLATE_DIR}"
    exit 1
fi

# Generate NGINX config
template_file
if [ "${TLS_ENABLED}" = "true" ]; then
    template_file="${TEMPLATE_DIR}/https.tpl.conf"
else
    template_file="${TEMPLATE_DIR}/http.tpl.conf"
fi

# Use environment substitution for the SERVER_NAME
envsubst '$SERVER_NAME' < "${template_file}" > "${NGINX_CONF_DIR}/credsvr.conf"

# Start NGINX in the foreground
if [ "${TLS_ENABLED}" = "true" ]; then
    echo "Vessel started with HTTPS"
else
    echo "Vessel started with HTTP"
fi
nginx -g 'daemon off;'
