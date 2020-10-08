# Deploy containers related to the EVIDENCE project 
- Später muss dass alles durch IaC ersetzt werden (z.B. Ansible) -> Dies ist kein Production Code!
- Die Bash-Skripte sind ganz nett um local die Container zu starten -> Es ist nur Dev code!

## Install

```sh
# Clone the master repo
git clone git@github.com:ulf1/deploy-evidence.git
# Install given submodules
git submodule update --init --recursive
```


## git submodules

### Add another submodule

```sh
git submodule add git@github.com:ulf1/fastapi-evidence-restapi.git restapi
git submodule add git@github.com:ulf1/psql-evidence-database.git database
git submodule add git@github.com:ulf1/vue-evidence-app.git webapp
```

