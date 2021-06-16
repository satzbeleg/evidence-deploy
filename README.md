# EVIDENCE project - Deploy Container


## Installation
Die EVIDENCE-Subsysteme (z.B. API, DB, App, Modell) werden in separaten Repositorien entwickelt, und hier als submodules eingebunden.

```sh
# Clone the master repo
git clone git@github.com:satzbeleg/deploy-evidence.git
# go to folder
cd deploy-evidence
# Install given submodules
git submodule update --init --recursive
```

## .env.local (Setze den API Endpoint)
Die REST API muss für die WebApp konfiguriert werden.

```sh
nano webapp/.env.local
```

```
NODE_ENV=local
RESTAPI_URL=evidence.bbaw.de
```

## Branches
* `main` (main branch): Die Submodule verweisen auf die Github Repos im [@satzbeleg](https://github.com/satzbeleg) Benutzerkonto.
* `dev` -- Development branch für `main` branch. 


## IPs und Ports

| Container | Docker IP | Docker Port | Host Port |
|:---------:|:-----------:|:-------------:|:---------:|
| `evidence-app`      | `172.20.253.1` | `8080` | `55018` |
| `evidence-restapi`  | `172.20.253.2` | `80` | `55017` |
| `evidence-dbappl_manager` | `172.20.253.4` | --- | --- |
| `evidence-dbappl_master` | `172.20.253.5` | `5432` | `55015` |
| `evidence-dbappl_worker_#` | `172.20.253.129-254` (dynamisch) | --- | --- |
| `evidence-pgadmin4` | `172.20.253.6` | `80` | `55016` |
| `evidence-dbauth` | `172.20.253.7` | `5432` | `55014` |


Docker Port Ranges `evidence-network`

- Docker Port Range `172.20.253.0/24`
    - Network address: `172.20.253.0`
    - Broadcast: `172.20.253.255`
    - Usable: `172.20.253.1-254` (254x)
- Dynamisch: `172.20.253.129-254` (126x)




## Docker starten

```sh
# Host Server's Port Settings
export DBAUTH_HOSTPORT=55014
export DBAPPL_HOSTPORT=55015
export PGADMIN_HOSTPORT=55016
export RESTAPI_HOSTPORT=55017
export WEBAPP_HOSTPORT=55018


# Postgres Settings
export DBAPPL_PASSWORD=password1234
export DBAUTH_PASSWORD=password1234
# Persistent Storage
#rm -rf tmp
mkdir -p tmp/{data_evidence,data_userdb}
export DBAPPL_PERSISTENT=./tmp/data_evidence
export DBAUTH_PERSISTENT=./tmp/data_userdb

# PgAdmin Settings
export PGADMIN_EMAIL=test@mail.com
export PGADMIN_PASSWORD=password1234

# REST API Settings
export RESTAPI_NUM_WORKERS=2
export RESTAPI_SECRET_KEY=$(openssl rand -hex 32)
export RESTAPI_TOKEN_EXPIRY=1440  # in minutes

# Subproject folders
export RESTAPI_PATH=./restapi
export WEBAPP_PATH=./webapp
export DATABASE_PATH=./database

docker compose -p evidence -f network.yml \
    -f ${DATABASE_PATH}/dbappl.yml \
    -f ${DATABASE_PATH}/dbauth.yml \
    -f ${DATABASE_PATH}/pgadmin.yml \
    -f ${RESTAPI_PATH}/restapi.yml \
    -f ${WEBAPP_PATH}/webapp.yml \
    up --build

# for dbappl.yml
docker-compose -p evidence scale worker=2
```

## Anhang

### Git submodule
Ein Git submodule kann mit folgenden Befehlen hinzugefügt werden. 
Siehe `.gitmodule` Datei.

```sh
git submodule add git@github.com:satzbeleg/evidence-restapi.git restapi
git submodule add git@github.com:satzbeleg/evidence-database.git database
git submodule add git@github.com:satzbeleg/evidence-app.git webapp
```
