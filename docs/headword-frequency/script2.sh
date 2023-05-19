#!/bin/bash

export CQLNAME=zdl_evidence_dbeval

# download all rows
docker exec -i zdl_evidence_dbeval cqlsh -e 'COPY evidence.tbl_features (headword) TO STDOUT' > headwords-all-rows.txt

# group by headword and count
cat headwords-all-rows.txt | sort | uniq -c | sort -nr > headwords.txt
