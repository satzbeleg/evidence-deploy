import cassandra as cas
import cassandra.cluster
import cassandra.query
import cassandra.policies
import gc
import csv


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


def get_headwords(session: cas.cluster.Session,
                  max_fetch_size: int = 1000000):
    # prepare statement
    stmt = cas.query.SimpleStatement(
        f"SELECT DISTINCT headword FROM {session.keyspace}.tbl_features",
        fetch_size=max_fetch_size)
    # fetch from CQL
    headwords = []
    for row in session.execute(stmt):
        try:
            headwords.append(row.headword)
        except Exception as err:
            print(err)
    headwords = list(set(headwords))
    # clean up
    del stmt
    gc.collect()
    # done
    return headwords


def get_num_per_headword(session: cas.cluster.Session, 
                         headword: str):
    try:
        # prepare statement
        stmt = session.prepare(
            f"SELECT COUNT(sent_id) FROM {session.keyspace}.tbl_features WHERE headword=?;")
        # fetch from CQL
        for row in session.execute(stmt, [headword]):
            num = row.system_count_sent_id
            break
    except Exception as err:
        print(err)
        num = None
    finally:
        # clean up
        del stmt
        gc.collect()
    # done
    return num


# Open connection
conn = CqlConn("evidence")
session = conn.get_session()

# download all headwords
headwords = get_headwords(session)

# download number of sentences per headword
result = []
for headword in headwords:
    num = get_num_per_headword(session, headword)
    result.append((headword, num))


# write results
with open('headword-freq.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, dialect='excel')
    writer.writerow(["headword", "freq"])
    for row in result:
        writer.writerow(row)

# done
conn.shutdown()
