#!/bin/bash

export CQLNAME=zdl_evidence_dbeval

# download all headwords (CQL partition keys)
docker exec -i $CQLNAME cqlsh --encoding=utf8 --no-color --request-timeout=6000 -e'SELECT DISTINCT headword FROM evidence.tbl_features;' > headwords.txt

# clean up file
cat headwords.txt | tail -n +5 | head -n -2 | sed 's/^ *//;s/ *$//' > headwords2.txt

# for each headword, get the frequency
echo "headword,frequency" > headword-frequencies.csv
while IFS= read -r line; do
    docker exec -i $CQLNAME cqlsh --encoding=utf8 --no-color --request-timeout=6000 -e"SELECT COUNT(sent_id) FROM evidence.tbl_features WHERE headword='${line}';" > tmpres
    value=$(cat tmpres | tail -n +4 | head -n -2 | sed 's/^ *//;s/ *$//')
    rm tmpres
    echo "${line},${value}" >> headword-frequencies.csv
done < headwords2.txt
