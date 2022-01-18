[![Join the chat at https://gitter.im/satzbeleg/community](https://badges.gitter.im/satzbeleg/community.svg)](https://gitter.im/satzbeleg/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# EVIDENCE project - Deploy Container


## Purpose
This repository integrates the [Web App](https://github.com/satzbeleg/evidence-app), [REST API](https://github.com/satzbeleg/evidence-restapi) and [databases](https://github.com/satzbeleg/evidence-database) as git submodules,
and builds all required Docker containers to deploy the EVDIENCE WebApp with its backend.


## Installation
1. [Download the Code](#download-the-code)
2. [Customize Settings](#customize-settings)
3. [Build Docker Containers](#build-docker-containers)

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


### Customize Settings
Create a file `specific.env.sh` and change settings according to your deployment scenario.

```sh
cp defaults.env.sh specific.env.sh
nano specific.env.sh
```


### Build Docker Containers

```sh
# load environment variables
set -a
source defaults.env.sh
source specific.env.sh

# Start containers
# - WARNING: Don't use the `docker compose` because it cannot process `ipv4_address`!
docker-compose -p evidence -f network.yml \
    -f ${DATABASE_PATH}/dbappl.yml \
    -f ${DATABASE_PATH}/dbauth.yml \
    -f ${RESTAPI_PATH}/restapi.yml \
    -f ${WEBAPP_PATH}/webapp.yml \
    up --build

# for dbappl.yml
docker-compose -p evidence -f network.yml -f ${DATABASE_PATH}/dbappl.yml scale worker=3
```

## Add Demo Toy Data
```sh
cat database/dbappl/demo/toy-data-for-app-demo.sql | docker exec -i evidence-dbappl_master psql --username=postgres

cat database/dbauth/demo/test-user-for-app-demo.sql | docker exec -i evidence-dbauth psql --username=postgres
```



## Appendix

### `network.yml` -- Docker Network
The docker network `evidence-network` will occupy the following port ranges within the docker subnets.

- Docker Port Range `172.20.253.0/24`
    - Network address: `172.20.253.0`
    - Broadcast: `172.20.253.255`
    - Usable: `172.20.253.1-254` (254x)
- Dynamic: `172.20.253.129-254` (126x)



### `specific.env.sh` -- Host Ports
The docker IP and ports of each container are mapped to a host port.
You can set the desired host ports to your needs.


| Container | Docker IP | Docker Port | Host Port | `specific.env.sh` |
|:---------:|:-----------:|:-------------:|:---------:|:---------:|
| `evidence-app`      | `172.20.253.1` | `8080` | `55018` | `WEBAPP_HOSTPORT` |
| `evidence-restapi`  | `172.20.253.2` | `80` | `55017` | `RESTAPI_HOSTPORT` |


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
