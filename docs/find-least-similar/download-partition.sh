#!/bin/bash

export CQLNAME=zdl_evidence_dbeval

export HEADWORD=Tisch

read -r -d '' QUERY << EOM
SELECT headword, example_id, sentence, sent_id, score
     , feats1, hashes15, hashes16, hashes18
FROM evidence.tbl_features
WHERE headword='${HEADWORD}'
EOM


docker exec -i $CQLNAME cqlsh --encoding=utf8 --no-color --request-timeout=6000 -e "$QUERY" > "partition-$HEADWORD.txt"
