# EVIDENCE project - Deploy Container


## Installation
Die EVIDENCE-Subsysteme (z.B. API, DB, App, Modell) werden in separaten Repositorien entwickelt, und hier als submodules eingebunden.

```sh
# Clone the master repo
git clone git@github.com:ulf1/deploy-evidence.git
# go to folder
cd deploy-evidence
# Install given submodules
git submodule update --init --recursive
```


## Starte, Stoppe und Lösche Container
**TODO**: Ersetze die `run.sh` und `docker-compose` später durch Ansible (IaC).


### Starte DEV Mode
Das Skript `start.sh` baut und startet die Backend Container (`-b` flag) und Frontend Container (`-f` flag) als Hintergrundprozess.
In der CLI kann wird `docker ps` im Livemodus angezeigt (`-w` flag).

```bash
bash run.sh -b -f -w
```

Durch Drücken der `[Ctrl+C]` Tastenkombination werden die Container beendet. 
(Bitte checke mit dem `docker ps -a` Befehl.)


### Starte Production Mode
Für den Betrieb sollten die Container einfach gestartet werden.

```bash
bash run.sh -b -f
```


### Stoppe Container
Alle Container mit dem Namen `"evidence-*"` werden angehalten.
(Es wird das Programm `docker` statt `docker-compose` benutzt.)

```bash
bash run.sh -s
```


### Lösche Container und Images (Tabula Rasa)
Das Skript `delete.sh` löscht alle `"evidence-*"` Container und auch Images.
Die Daten (z.B. in Datenbanken) werden ebenfalls gelöscht.

```bash
bash run.sh -d
```


## Anhang

### Git submodule
Ein Git submodule kann mit folgenden Befehlen hinzugefügt werden. 
Siehe `.gitmodule` Datei.

```sh
git submodule add git@github.com:ulf1/fastapi-evidence-restapi.git restapi
git submodule add git@github.com:ulf1/psql-evidence-database.git database
git submodule add git@github.com:ulf1/vue-evidence-app.git webapp
```
