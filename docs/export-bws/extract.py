import json
import bwsample as bws

# Achtung! Man muss es eventuell für 3 und 5 seperat laufen lassen.
# Die Ergebnisse von `bws.count` müssen dann aggregiert werden.
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

