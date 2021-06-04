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

```sh
nano webapp/.env.local
```

```
NODE_ENV=local
#VUE_APP_API_URL=http://riker.bbaw.de:55017
VUE_APP_API_URL=https://riker.bbaw.de
```

## Branches
* `master` (main branch): Die Submodule verweisen auf die Github Repos im [@satzbeleg](https://github.com/satzbeleg) Benutzerkonto.
* `dev` -- Development branch für `master` branch. 


## IPs und Ports


| Container | Internal IP | Internal Port | Host Port |
|:---------:|:-----------:|:-------------:|:---------:|
| `evidence-database_manager` | `172.20.253.4` | --- | --- |
| `evidence-database_master` | `172.20.253.5` | `5432` | `55015` |
| `evidence-database_worker_#` | `172.20.253.9-14` (dynamisch) | --- | --- |
| `evidence-pgadmin4` | `172.20.253.6` | `80` | `55016` |
| `evidence-restapi`  | `172.20.253.7` | `80` | `55017` |
| `evidence-app`      | `172.20.253.17` | `8080` | `55018` |


Internal Port Ranges `evidence-backend-network`

- Internal Port Range `172.20.253.0/28`
    - Network address: `172.20.253.0`
    - Broadcast: `172.20.253.15`
    - Usable: `172.20.253.1-14` (14x)
- Dynamisch: `172.20.253.8/29`
- Statisch: `172.20.253.1-7` (7x)

Internal Port Ranges `evidence-frontend-network`

- Internal Port Range `172.20.253.16/29`
    - Network address: `172.20.253.16`
    - Broadcast: `172.20.253.23`
    - Usable: `172.20.253.17-22` (6x)
- Dynamisch: `172.20.253.20/30` 
- Statisch: `172.20.253.17-19` (3x)


## Docker starten

```sh
# Host Server's Port Settings
export DATABASE_HOST_PORT=55015
export PGADMIN_HOST_PORT=55016
export RESTAPI_HOST_PORT=55017
export WEBAPP_HOST_PORT=55018

# Postgres Settings
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=password1234
# Persistent Storage
mkdir -p tmp/data
export POSTGRES_DATA=./tmp/data

# PgAdmin Settings
export PGADMIN_EMAIL=test@mail.com
export PGADMIN_PASSWORD=password1234

# REST API Settings
export RESTAPI_NUM_WORKERS=2

docker compose -p evidence up --build 
docker-compose -p evidence scale worker=2
#docker compose -p evidence rm
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
