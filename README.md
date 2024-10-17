# Vessel - Simple ACDC Schema Server

A vessel is a hollow container, like an ACDC schema.

NGINX server hosting static ACDC schemas

## Schema Files and Directories

- `/schemas_raw`: Raw schema files that have not been SAIDified. Put your new schemas here.
- `/schemas_saidified`: Schemas that have been SAIDified go here.
- `/schemas_renamed`: NGINX serves files by file name so the SAIDified schemas are renamed based on their SAD into this directory so their OOBI is correct.
- `/schema_rules`: As a related convenience for ACDC issuance the rules section for each schema end up here.

## NGINX Hosting

The Docker container hosts
