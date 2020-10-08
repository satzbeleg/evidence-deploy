# Deploy containers related to the EVIDENCE project 
- Später muss dass alles durch IaC ersetzt werden (z.B. Ansible) -> Dies ist kein Production Code!
- Die Bash-Skripte sind ganz nett um local die Container zu starten -> Es ist nur Dev code!


## Install
Die EVIDENCE-Subsysteme (z.B. API, DB, App, Modell) werden in seperaten Repos entwickelt, 
und hier als submodules eingebunden.

```sh
# Clone the master repo
git clone git@github.com:ulf1/deploy-evidence.git
# Install given submodules
git submodule update --init --recursive
```


## Starte die Container
Das Skript `start.sh` baut und startet die Container als Hintergrundprozess.
In der CLI kann wird `docker ps` im Livemodus angezeigt.

```sh
bash start.sh
```

Durch Drücken der `[Ctrl+C]` Tastenkombination werden die Container beendet. 
(Zumindestens sollte es so ein. Bitte checke mit dem `docker ps -a` Befehl.)


## Aufräumen
Das Skript `delete.sh` löscht alle `"evidence-*"` Container und auch Images.


## git submodules

### Add another submodule

```sh
git submodule add git@github.com:ulf1/fastapi-evidence-restapi.git restapi
git submodule add git@github.com:ulf1/psql-evidence-database.git database
git submodule add git@github.com:ulf1/vue-evidence-app.git webapp
```

