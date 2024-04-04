import random

import pymongo
from locust import between, events

import logging

from mongo_user import MongoUser, mongodb_task
from settings import DEFAULTS
from fixture_uuid import uuid4_list


CLIENT = pymongo.MongoClient(DEFAULTS["CLUSTER_URL"])


class MongoSampleUser(MongoUser):
    """
    Generic sample mongodb workload generator
    """

    # no delays between operations
    wait_time = between(0.0, 0.0)

    def __init__(self, environment):
        super().__init__(environment)
        self.unique_id_list = uuid4_list
        self.admin_client = CLIENT["admin"]

    def generate_new_document(self, identifiantPersonne):
        """
        Generate a new sample document
        """
        document = {
            "namespace": "com.bnpparibas",
            "nomenclatureEv": self.faker.uuid4(),  # Generating a random UUID for nomenclatureEv
            "eventId": str(self.faker.uuid4()),  # Generating a random UUID for eventId
            "dateTimeRef": self.random_datetime_within_x_days(90),
            "schemaVersion": "1.0",
            "headerVersion": "1.0",
            "idEtablissement": self.faker.word(),
            "canal": self.faker.random_int(
                1, 10
            ),  # Random integer between 1 and 10 for canal
            "serveur": self.faker.word(),
            "adresseIP": self.faker.ipv4(),
            "media": self.faker.random_int(
                1, 5
            ),  # Random integer between 1 and 5 for media
            "idTelematique": self.faker.numerify(
                "###############"
            ),  # Generating a random numeric string
            "identifiantPersonne": identifiantPersonne,  # Random identifier
            "grilleIdent": self.faker.random_int(
                1, 100
            ),  # Random integer between 1 and 100 for grilleIdent
            "codeRetour": self.faker.random_int(
                200, 500
            ),  # Random integer between 200 and 500 for codeRetour
            "referer": self.faker.word(),
            "browserVersion": f"{self.faker.random_int(1, 10)}.{self.faker.random_int(1, 10)}.{self.faker.random_int(1, 10)}",
            "androidUDID": self.faker.uuid4(),
            "iosIDFA": self.faker.uuid4(),
            "appVersion": f"{self.faker.random_int(1, 5)}.{self.faker.random_int(1, 5)}.{self.faker.random_int(1, 5)}",
            "idTmx": self.faker.uuid4(),
            "iosIDFV": self.faker.uuid4(),
            "androidInstanceId": self.faker.uuid4(),
            "eventIdDemande": f"eventIdDemande_{self.faker.random_int(1, 100)}",  # Random eventIdDemande
            "declenchementAF": f"declenchementAF_{self.faker.random_int(1, 100)}",  # Random declenchementAF
            "validationAF": f"validationAF_{self.faker.random_int(1, 100)}",  # Random validationAF
            "modeValidationAF": f"modeValidationAF_{self.faker.random_int(1, 100)}",  # Random modeValidationAF
            "origineAF": f"origineAF_{self.faker.random_int(1, 100)}",  # Random origineAF
            "statut": f"statut_{self.faker.random_int(1, 100)}",  # Random statut
        }
        return document

    def on_start(self):
        """
        Executed every time a new test is started - place init code here
        """
        # prepare the collection
        # We don't create any index here because we're only populating the database.

        self.collection, self.collection_secondary = self.ensure_collection(
            DEFAULTS["EVENTS_COLLECTION"]
        )

    @mongodb_task(weight=int(DEFAULTS["INSERT_ONE_DOC_WEIGHT"]))
    def insert_one_doc(self):
        """
        This function will insert a new document generated with "generate_new_document" inside the the collection "EVENTS_COLLECTION"
        The id of the new_document is found inside the self.unique_id_list list which stores the id of the newly generated documents.
        Why insert one document and not a bunch because in the case of BNP_Paribas, a connection is equal to one document transferred to the database.
        """

        self.collection.insert_one(
            self.generate_new_document(random.choice(self.unique_id_list))
        )

    @mongodb_task(weight=int(DEFAULTS["CHECK_MONGO_SIZE"]))
    def check_mongo_size(self):
        """
        Test designed to stop the worker when the db is loaded
        """
        size_in_mb = self.admin_client.command("listDatabases")["totalSizeMb"]
        logging.info("Current size in the database is %s MB", size_in_mb)

        # If there is enough data in the database, stop inserting
        if size_in_mb >= int(DEFAULTS["MB_TRESHOLD"]):
            logging.debug(f"### {DEFAULTS['MB_TRESHOLD']} MB LIMIT REACHED ###")
            self.environment.runner.quit()
