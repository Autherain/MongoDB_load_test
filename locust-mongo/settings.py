import os

DEFAULTS = {
    "DB_NAME": "sample",
    "COLLECTION_NAME": "documents",
    # "CLUSTER_URL": "mongodb://nosql:nosql@localhost:27017/?authMechanism=DEFAULT",
    "CLUSTER_URL": "mongodb+srv://my-user:123@example-mongodb-svc.default.svc.cluster.local/admin?replicaSet=example-mongodb&ssl=false",
    "INSERT_ONE_DOC_WEIGHT": 1000,
    "READ_LAST_90_DOC_WEIGHT": 1,
    "INSERT_SCORED_EVENT": 1,
    "EVENTS_COLLECTION": "events",
    "SCORES_COLLECTION": "scores",
    "CHECK_MONGO_SIZE": 1,
    # empiric value found when using machines such as t2.medium
    "MB_TRESHOLD": 400,
    "INSERT_MANY_DOCS_WEIGHT": 10,
    "NUM_DOCS_TO_INSERT": 10,
    "QUERY_BY_EVENTID_BY_DATE": 1,
    "QUERY_BY_IDENTIFIANT_PERSONNE_BY_DATE_BY_ADRESSE_IP": 1,
    "QUERY_BY_IDENTIFIANT_PERSONNE_BY_DATE": 1,
    "QUERY_BY_ADRESSE_IP_BY_DATE": 1,
    "QUERY_BY_IDENTIFIANT_PERSONNE_90_DAYS": 1,
}


def init_defaults_from_env():
    for key in DEFAULTS.keys():
        value = os.environ.get(key)
        if value:
            DEFAULTS[key] = value


# get the settings from the environment variables
init_defaults_from_env()
