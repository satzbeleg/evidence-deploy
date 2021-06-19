#!/bin/bash 

# Subproject folders
export RESTAPI_PATH=./restapi
export WEBAPP_PATH=./webapp
export DATABASE_PATH=./database

# Public URLs exposed to the Internet (or Intranet)
export PUBLIC_DOMAIN=localhost
#export PUBLIC_DOMAIN=test.example.com

# Host Server's Port Settings
export DBAUTH_HOSTPORT=55014
export DBAPPL_HOSTPORT=55015
export PGADMIN_HOSTPORT=55016
export RESTAPI_HOSTPORT=55017
export WEBAPP_HOSTPORT=55018

# Application Database (DB, API)
# - see database/dbappl.yml
# - see restapi/restapi.yml
export DBAPPL_PASSWORD=password1234
#export DATABASE_PATH=./database

# Authentification Database (DB, API)
# - see database/dbauth.yml 
# - see restapi/restapi.yml
export DBAUTH_PASSWORD=password1234
#export DATABASE_PATH=./database

# Persistent Storage (DB)
#rm -rf tmp
mkdir -p tmp/{data_evidence,data_userdb}
export DBAPPL_PERSISTENT=./tmp/data_evidence
export DBAUTH_PERSISTENT=./tmp/data_userdb

# PgAdmin Settings (DB)
# - see database/dbauth.yml 
export PGADMIN_EMAIL=test@mail.com
export PGADMIN_PASSWORD=password1234


# Performance Settings (API)
# - see restapi/restapi.yml
export RESTAPI_NUM_WORKERS=1

# CORS Exemption Settings (API, WEB)
# - see webapp/webapp.yml
# - see restapi/restapi.yml
# - Already specified above: WEBAPP_HOSTPORT, PUBLIC_DOMAIN

# Access Token Settings (API)
export ACCESS_SECRET_KEY=$(openssl rand -hex 32)
export ACCESS_TOKEN_EXPIRY=1440  # in minutes

# Mailer settings for Verfication Mails (API)
export SMTP_SERVER="smtp.example.com"
export SMTP_PORT=587
export SMTP_TLS=1
export SMTP_USER="nobody"
export SMTP_PASSWORD="supersecret"
export FROM_EMAIL="nobody@example.com"
export VERIFY_PUBLIC_URL="http://localhost:${RESTAPI_HOSTPORT}"
#export VERIFY_PUBLIC_URL="https://${PUBLIC_DOMAIN}:${WEBAPP_HOSTPORT}"


# WebApp
# - see webapp/webapp.yml
# - Already specified above: WEBAPP_PATH, WEBAPP_HOSTPORT
export REST_PUBLIC_URL="http://localhost:${RESTAPI_HOSTPORT}"
#export REST_PUBLIC_URL="https://${PUBLIC_DOMAIN}:${RESTAPI_HOSTPORT}"
