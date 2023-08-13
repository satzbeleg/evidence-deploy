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

### Add Deployment Specific Configurations

##### Configurations to build the Web-App information
The Web-App uses environement variables before running `yarn build` (e.g. in the `Dockerfile`).
In other workds, these environment variables are hardcoded into the Web-App,
and exposed in the client ([more information](https://cli.vuejs.org/guide/mode-and-env.html)).

- Edit `./webapp/.env` 
- Set `NODE_ENV=production` to enable the PWA workers
- Specify the URL of the REST API (`VUE_APP_REST_PUBLIC_URL`)
- Specify the Google Client ID if you setup User Verfication with GCP (`VUE_APP_GOOGLE_CLIENT_ID`)

##### Configurations for the E-Mail Authentification in the REST API image
The REST API needs an SMTP-Server for the E-Mail based user registration. 

- Edit `./docker-compose.yml`
- Scroll to the `api` service
- Edit the ENV variables `SMTP_SERVER`, `SMTP_PORT`, ..., `VERIFY_PUBLIC_URL`


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
- http://localhost:7070/v1/docs (API for Web-App)
- http://localhost:8025/ (stub SMTP server)


Please configure your mailer settings, and gunicorn settings for the `api` container.



## Upload Docker Images to Registry

##### Example: ZDL Registry
First, login 
```sh
docker login docker-registry.zdl.org
```
Then run this script
```sh
python3 scripts/push-images-to-zdl
```


##### Reploy only the Web-App
Sometimes, minor bugs occur in the Web-App code. 
It is not necessary to trigger a full redeployment because the Web-App only uses a container to build once, while the built code is served via a NGINX server.

```
cd webapp
nvm install 16
yarn
yarn build
scp -r dist username@yourserver.com:~/tmp-evidence-htdocs
ssh username@yourserver.com
sudo rm -r yournginxfolder/*
sudo cp -r ~/tmp-evidence-htdocs/* yournginxfolder/
rm -r ~/tmp-evidence-htdocs
exit
cd ..
```

(Hint for ZDL: Check `zdl_evidence_data_dir / htdocs` in zdl/ansible repo.)



## Backup and Recovery (dbauth)
The *backup* should be carried out in the database container, i.e. `pg_dump` is executed in the container and the data is forwarded to the host.
The reason is that the program `pg_dump` on the host might not have to have the same major version as the Postgres database in the container.

```sh
suffix=$(date +"%Y-%m-%dT%H-%M")
docker exec -it evidence_auth bash \

docker-compose exec dbauth \
    pg_dump -U evidence evidence \
    | gzip -9 > "postgres-${suffix}.sql.gz"
```

For *recovery*, the archive is forwarded from the host to the database container,
and used as input in the container of `psql`.

```sh
gunzip -c "postgres-${suffix}.sql.gz" | docker-compose exec -T dbauth \
   psql -U evidence evidence
```



## Data Preprocessing
We still need to preprocess text corpora and ingest it into the Cassandra database.
The preprocessing pipeline is done un 

- [https://github.com/satzbeleg/evidence-features](https://github.com/satzbeleg/evidence-features)




## DSGVO
- `dbauth`: 
    - A Postgres database `auth` for the authentication process (e.g. email for account recovery, passwords, Google ID for OAuth).
    - External applications only receive the `user_id`, which are random UUID4 strings, and thus represent *pseudonyms* according to Art. 4 No. 5 DSGVO (i.e. the `user_id` can be stored permanently in external applications because these are pseudonymized by design).
    - It is also a datbase `userdata` included to store user settings.
- `dbeval`: 
    - A Cassandra database to store the examples to evaluate and evaluation results
    - The database does **not** store permanently *direkte personenbezogenen Daten* (DSGVO). Otherwise further functionalities have to be implemented (e.g. deletion requests of direct personal data).
    - The database can store **temporarily** *direkte personenbezogenen Daten* (DSGVO) for sole purpose of a non-commercial research project, e.g. user surveys with the informed consent that provided data can be published under CC-* license.
    - The application stores `user_id` permanently as *Pseudonym* (Art. 4 Nr. 5 DSGVO).



## Common Problems
When re-building images it is very likely that errors occur that needs debugging.

### Outdated Dependencies
We already observed security related package version problems (e.g. SSL errors, outdate certificates and key),
and "dependency hell" problems with deprecated packages.
Please check:

- `./webapp/package.json` -- Often only the tooling packages ("dev" packages) get outdated over time because the development framework keep evolving.
- `./restapi/requirements.txt` 
- `./features/{setup.py, requirements.txt}` 


## Appendix

### Submodules
A Git submodule can be added with the following commands.
See `.gitmodule` file.

```sh
git submodule add git@github.com:satzbeleg/evidence-restapi.git restapi
git submodule add git@github.com:satzbeleg/evidence-database.git database
git submodule add git@github.com:satzbeleg/evidence-app.git webapp
```

### Branches
* `main` (main branch): The submodules refer to the Github repos of the organization [@satzbeleg](https://github.com/satzbeleg).
* `dev` -- Development branch for `main` branch. 


### Support
Please [open an issue](https://github.com/satzbeleg/evidence-deploy/issues/new) for support.


### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-deploy/compare/).
You are asked to sign the CLA on your first pull request.
