# Export BWS annotations


## Usage `script.sh` 

1. Login into database server

2. Set container name

```sh
export CQLNAME=zdl_evidence_dbeval
```

3. Run script

```sh
nohup docker exec -i $CQLNAME cqlsh --encoding=utf8 --no-color --request-timeout=6000 -e'SELECT set_id, user_id, ui_name, headword, event_history, state_sentid_map, tracking_data FROM evidence.evaluated_bestworst;' > data-bws.txt &
```

```
tail -n 3 data-bws.txt
```

## Usage `script.sh` (COPY Methode)

```sh
# nohup docker exec -i $CQLNAME cqlsh -e 'COPY evidence.evaluated_bestworst (set_id, user_id, ui_name, headword, event_history, state_sentid_map, tracking_data) TO STDOUT' > data-bws.csv &
```

```sh
# tail -n 3 data-bws.csv
```


## Extract Pairs with bwsample

```sh
python3 -m venv .venv
source .venv/bin/activate
pip3 install --upgrade pip
pip install bwsample
```


```py
import json
import bwsample as bws

NUM_OF_ITEMS_PER_BWSSET = 4
evaluations = []
with open("data-bws.txt", "r") as fp:
    for line in fp:
        try:
            # split string
            row = line.split("|", 6)
            if len(row) != 7:
                continue
            # parse json
            row[4] = json.loads(row[4])
            row[5] = json.loads(row[5])
            # check if BWS set was submitted
            if row[4][-1].get('message') == 'submitted':
                states = row[4][-2].get('state')
                ids = [v for _, v in sorted(row[5].items())]
                if len(states) == len(ids) == NUM_OF_ITEMS_PER_BWSSET:
                    evaluations.append((states, ids))
        except Exception as e:
            print(e)
            pass

agg_dok, direct_dok, direct_detail, logical_dok, logical_detail = bws.count(
    evaluations, logical_database=evaluations)

ranked, ordids, metrics, scores, info = bws.rank(
    agg_dok, method='approx')
```

The plain sentence text is not stored in the table `evidence.evaluated_bestworst` and must be looked up from `evidence.tbl_features`.
