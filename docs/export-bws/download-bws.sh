#!/bin/bash

export CQLNAME=zdl_evidence_dbeval

export HEADWORD=Tisch

read -r -d '' QUERY << EOM
SELECT set_id, user_id, ui_name, headword
     , event_history
     , state_sentid_map
     , tracking_data 
FROM evidence.evaluated_bestworst;
EOM


docker exec -i $CQLNAME cqlsh --encoding=utf8 --no-color --request-timeout=6000 -e "$QUERY" > data-bws.txt
