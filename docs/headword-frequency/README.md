# Headwords with frequencies (Lemmata mit Frequenzen)

## Warning
- Cassandra will likely time out when attempting something like `SELECT DISTINCT headword, COUNT(*) ...`
- The approach is to download the headwords first, what are the CQL partition keys. Afterwards count the rows for each partition. 

## Usage

1. Login into database server

2. Setup a virtual venv and install cassandra package

```
python3 -m venv .venv
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
```

3. Run the script in the background

```
nohup python script.py > freq-download.log &
```

4. Copy the results to tour computer

```
scp username@server:~/somewhere/headword-freq.csv headword-freq.csv
```
