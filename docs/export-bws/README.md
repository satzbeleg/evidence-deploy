# Export BWS annotations


1. Login into database server

2. Run script

```sh
nohup download-bws.sh &
```

```sh
tail -n 3 data-bws.txt
```


3. Extract Pairs with bwsample and compute scores

```sh
python3 -m venv .venv
source .venv/bin/activate
pip3 install --upgrade pip
pip install bwsample
```

```sh
python extract.py
```

4. Client-Join to map sentence features

The plain sentence text is not stored in the table `evidence.evaluated_bestworst` and must be looked up from `evidence.tbl_features` ==> See download.sh in `find-least-similar/download-partition.sh`
