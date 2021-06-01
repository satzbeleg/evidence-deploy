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
* `master` (main branch): Die Submodule verweisen auf die Github Repos im [@ulf1](https://github.com/ulf1) Benutzerkonto.
* `dev` -- Development branch für `master` branch. 


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


### Logs anschauen

```sh
tail -f logs/webapp.log
tail -f logs/restapi.log
tail -f logs/database.log
```

## IPs und Ports


| Container | Internal IP | Internal Port | Host Port |
|:---------:|:-----------:|:-------------:|:---------:|
| `evidence-database` | `172.20.253.5` | `5432` | `55015` |
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


## Anhang

### Git submodule
Ein Git submodule kann mit folgenden Befehlen hinzugefügt werden. 
Siehe `.gitmodule` Datei.

```sh
git submodule add git@github.com:ulf1/evidence-restapi.git restapi
git submodule add git@github.com:ulf1/evidence-database.git database
git submodule add git@github.com:ulf1/evidence-app.git webapp
```
