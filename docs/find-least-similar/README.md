# Find least (most) similar


### Howto
1. Select 1 lemma
2. Predict scores for all sentence examples
3. Select the top-500 sentences
4. For each i-th top-500, ...
    * randomly select 500 other sentence examples (of N)
    * compute the 1-500 similarities
    * find the 2 * 500/N percentile of the similarities p
    * loop randomly over all other sentence examples j
    * save (i,j) pair if similarity is lower than p
    * stop when 500 pairs were found
5. Mirror missing pairs along the matrix diagonal



## Usage `script.py`

1. Login into database server

2. Setup a virtual venv and install cassandra package

```
python3 -m venv .venv
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
```

3. Download the CQL parition of a lemma (headword)

```sh
nohup download-partition.sh &
wc -l partition-Tisch.txt
```

4. 
```
nohup python findsimi.py --infile=partition-Tisch.json
```

5. Copy the results to your computer

```
scp username@server:~/somewhere/headword-freq.csv headword-freq.csv
```


## Usage `script.sh` 

1. Login into database server

2. Set container name

```
export CQLNAME=zdl_evidence_dbeval
```

3. Run script

```
nohup bash script.sh > freq-download.log &
```

## Usage `script.sh` (COPY Methode)

```
nohup bash script2.sh > freq-download2.log &
```


