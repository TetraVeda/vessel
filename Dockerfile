# Vessel schema server Docker Image
FROM nginx:1.26.2

# NGINX configuration files
RUN mkdir -p /etc/nginx/tpl
COPY nginx/http.tpl.conf /etc/nginx/tpl/http.tpl.conf
COPY nginx/https.tpl.conf /etc/nginx/tpl/https.tpl.conf
COPY nginx/startup.sh /startup.sh

# Renamed, SAIDified schema files
COPY ./schemas_renamed /schemas

# Expose HTTPS port
EXPOSE 443 80

# Expects TLS certificates to be mounted to
#  - /etc/nginx/tls-combined-chain.pem   for the CA certificate chain and intermediate CA certs
#  - /etc/nginx/tls-key.pem              for the TLS key

CMD ["/startup.sh"]
