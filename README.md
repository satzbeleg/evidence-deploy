[![Join the chat at https://gitter.im/satzbeleg/community](https://badges.gitter.im/satzbeleg/community.svg)](https://gitter.im/satzbeleg/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# EVIDENCE project - Deploy Container


## Purpose
This repository integrates the [Web App](https://github.com/satzbeleg/evidence-app), [REST API](https://github.com/satzbeleg/evidence-restapi) and [databases](https://github.com/satzbeleg/evidence-database) as git submodules,
and builds all required Docker containers to deploy the EVDIENCE WebApp with its backend.


## Installation
1. [Download the Code](#download-the-code)
2. [Build Docker Containers](#build-docker-containers)
3. [Backup and Recovery](#backup-and-recovery)


### Download the Code
The EVIDENCE subsystems (e.g. [API](https://github.com/satzbeleg/evidence-restapi), [DB](https://github.com/satzbeleg/evidence-database), [app](https://github.com/satzbeleg/evidence-app)) are developed in separate repositories and integrated here as git submodules. First, clone the repository `satzbeleg/deploy-evidence` and enter the folder. Finally, pull the git submodules.

```sh
# Clone the master repo
git clone git@github.com:satzbeleg/evidence-deploy.git
# go to folder
cd evidence-deploy
# Install given submodules
git submodule update --init --recursive
```


### Build Docker Containers

```sh
docker-compose up --build
# docker-compose up --build dbauth dbeval dbeval-install
# docker-compose up --build dbauth dbeval mail
# docker-compose up --build dbauth dbeval mail api
# docker-compose up --build dbauth dbeval mail api app
```

Entry URLs:

- http://localhost:9090/ (Web-App)
- http://localhost:8080/v1/docs (API for Web-App)
- http://localhost:8025/ (stub SMTP server)


Please configure your mailer settings, and gunicorn settings for the `api` container.

### Backup and Recovery
The *backup* should be carried out in the database container, i.e. `pg_dump` is executed in the container and the data is forwarded to the host.
The reason is that the program `pg_dump` on the host might not have to have the same major version as the Postgres database in the container.

```sh
suffix=$(date +"%Y-%m-%dT%H-%M")
docker exec -it evidence_dbeval bash \

docker-compose exec dbeval \
    pg_dump -U evidence evidence \
    | gzip -9 > "postgres-${suffix}.sql.gz"
```

For *recovery*, the archive is forwarded from the host to the database container,
and used as input in the container of `psql`.

```sh
gunzip -c "postgres-${suffix}.sql.gz" | docker-compose exec -T db \
   psql -U evidence evidence
```

### Upload Docker Images to Registry

#### Example: ZDL Registry
First, login 
```sh
docker login docker-registry.zdl.org
```
Then run this script
```sh
python3 scripts/push-images-to-zdl
```


## Appendix


### Submodules
A Git submodule can be added with the following commands.
See `.gitmodule` file.

```sh
git submodule add git@github.com:satzbeleg/evidence-restapi.git restapi
git submodule add git@github.com:satzbeleg/evidence-database.git database
git submodule add git@github.com:satzbeleg/evidence-app.git webapp
git submodule add git@github.com:satzbeleg/evidence-features.git features
```

### Branches
* `main` (main branch): The submodules refer to the Github repos of the organization [@satzbeleg](https://github.com/satzbeleg).
* `dev` -- Development branch for `main` branch. 


### Support
Please [open an issue](https://github.com/satzbeleg/evidence-deploy/issues/new) for support.


### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-deploy/compare/).
You are asked to sign the CLA on your first pull request.
