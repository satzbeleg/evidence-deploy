# BENUTZE `download-partition.sh`
import cassandra as cas
import cassandra.cluster
import cassandra.query
import cassandra.policies
import gc
import jsonlines
import json
import argparse

# USAGE:
# nohup python download-partition.py --headword=Tisch &
# wc -l partition-Tisch.jsonl

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("--headword", help="headword to download")
args = parser.parse_args()


cas_exec_profile = cas.cluster.ExecutionProfile(
    load_balancing_policy=cas.policies.RoundRobinPolicy(),
    request_timeout=None,  # disable query timeout
)


class CqlConn:
    def __init__(self,
                 keyspace: str,
                 port: int = 9042,
                 contact_points=['0.0.0.0']
                 ):
        """ connect to Cassandra cluster """
        # connect to cluster
        self.cluster = cas.cluster.Cluster(
            contact_points=contact_points,
            port=port,
            protocol_version=5,
            idle_heartbeat_interval=0,
            reconnection_policy=cas.policies.ConstantReconnectionPolicy(
                1, None),
            execution_profiles={
                cas.cluster.EXEC_PROFILE_DEFAULT: cas_exec_profile},
        )
        # open an connection
        self.session = self.cluster.connect(
            wait_for_all_pools=False)
        # set `USE keyspace;`
        self.session.set_keyspace(keyspace)
    def get_session(self) -> cas.cluster.Session:
        return self.session
    def shutdown(self) -> None:
        self.session.shutdown()
        self.cluster.shutdown()
        gc.collect()
        pass



def get_partition(session: cas.cluster.Session,
                  headword: str,
                  file_name: str,
                  page_size: int = 10000):
    # download data
    try:
        # prepare statement
        stmt = cas.query.SimpleStatement(f"""
            SELECT headword, example_id, sentence, sent_id
                 , spans, annot, biblio, license, score
                 , feats1
                 , feats2, feats3, feats4, feats5
                 , feats6, feats7, feats8, feats9
                 , feats12, feats13, feats14
                 , hashes15, hashes16, hashes18
            FROM {session.keyspace}.tbl_features
            WHERE headword='{headword}';
            """, fetch_size=page_size)

        # read async fetched rows
        def process_results(results):
            examples = []
            for row in results:
                examples.append({
                    "headword": row.headword, 
                    "example_id": str(row.example_id), 
                    "sentence": row.sentence, 
                    "sentence_id": str(row.sent_id), 
                    "spans": json.dumps(row.spans), 
                    "annot": row.annot, 
                    "biblio": row.biblio, 
                    "license": row.license, 
                    "score": row.score,
                    "feats1": row.feats1,
                    "feats2": row.feats2,
                    "feats3": row.feats3,
                    "feats4": row.feats4,
                    "feats5": row.feats5,
                    "feats6": row.feats6,
                    "feats7": row.feats7,
                    "feats8": row.feats8,
                    "feats9": row.feats9,
                    "feats12": row.feats12,
                    "feats13": row.feats13,
                    "feats14": row.feats14,
                    "hashes15": row.hashes15,
                    "hashes16": row.hashes16,
                    "hashes18": row.hashes18,
                })
            # write to disk
            with jsonlines.open(file_name, mode='a') as writer:
                writer.write_all(examples)

        # start downloading
        paging_state = None
        proceed = True
        while proceed:
            # download 1 page of 'page_size' sentences
            future = session.execute_async(stmt)
            future.add_callback(process_results, paging_state=paging_state)
            results = future.result()
            # update paging state
            paging_state = results.paging_state
            proceed = future.has_more_pages

        # delete
        del stmt
        gc.collect()
    except Exception as err:
        print(err)
        gc.collect()


# Open connection
conn = CqlConn("evidence")
session = conn.get_session()

# download partition
get_partition(
    session, 
    headword=args.headword, 
    file_name=f"partition-{args.headword}.jsonl"
)

# done
conn.shutdown()
del conn, session
gc.collect()
