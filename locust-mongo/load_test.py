from datetime import datetime
import random
import logging
import uuid

import pymongo
from locust import between, events

from mongo_user import MongoUser, mongodb_task
from settings import DEFAULTS

from fixture_uuid import uuid4_list


class MongoSampleUser(MongoUser):
    """
    Generic sample mongodb workload generator
    """

    # no delays between operations
    wait_time = between(0.0, 0.0)

    def __init__(self, environment):
        super().__init__(environment)
        self.unique_id_list = uuid4_list
        self.nomenclature_ev_list = []
        self.event_id_list = []
        self.date_list = []

    def on_start(self):
        """
        Executed every time a new test is started - place init code here
        """

        # prepare the collection
        index1 = pymongo.IndexModel(
            [("dateTimeRef", pymongo.DESCENDING), ("eventIdt", pymongo.DESCENDING)],
            name="idx_dateTimeREf_last",
        )
        self.collection, self.collection_secondary = self.ensure_collection(
            DEFAULTS["EVENTS_COLLECTION"], [index1]
        )

        # Fetch data for nomenclatureEv, eventId, and dateTimeRef
        results = self.collection.find(
            {}, {"nomenclatureEv": 1, "eventId": 1, "dateTimeRef": 1, "_id": 0}
        ).limit(500)

        for result in results:
            self.nomenclature_ev_list.append(result["nomenclatureEv"])
            self.event_id_list.append(result["eventId"])
            self.date_list.append(result["dateTimeRef"])

    @mongodb_task(weight=int(DEFAULTS["QUERY_BY_EVENTID_BY_DATE"]))
    def query_by_eventid_by_date(self):
        result = self.collection.find(
            {
                "date": self.random_datetime_within_x_days(90),
                "eventId": random.choice(self.event_id_list),
            }
        )
        logging.debug("Query by event ID by date: {}".format(result))

    @mongodb_task(
        weight=int(DEFAULTS["QUERY_BY_IDENTIFIANT_PERSONNE_BY_DATE_BY_ADRESSE_IP"])
    )
    def query_by_identifiant_personne_by_date_by_adresse_ip(self):
        result = self.collection.find(
            {
                "date": self.random_datetime_within_x_days(90),
                "nomenclatureEv": random.choice(self.nomenclature_ev_list),
                "identifiantPersonne": random.choice(self.unique_id_list),
                "adresseIP": self.faker.ipv4(),
            }
        )
        logging.debug(
            "Query by identifiant personne by date by adresse IP: {}".format(result)
        )

    @mongodb_task(weight=int(DEFAULTS["QUERY_BY_IDENTIFIANT_PERSONNE_BY_DATE"]))
    def query_by_identifiant_personne_by_date(self):
        result = self.collection.find(
            {
                "date": self.random_datetime_within_x_days(90),
                "nomenclatureEv": random.choice(self.nomenclature_ev_list),
                "identifiantPersonne": random.choice(self.unique_id_list),
            }
        )
        logging.debug("Query by identifiant personne by date: {}".format(result))

    @mongodb_task(weight=int(DEFAULTS["QUERY_BY_ADRESSE_IP_BY_DATE"]))
    def query_by_adresse_ip_by_date(self):
        result = self.collection.find(
            {
                "date": self.random_datetime_within_x_days(90),
                "nomenclatureEv": random.choice(self.nomenclature_ev_list),
                "adresseIP": self.faker.ipv4(),
            }
        )
        logging.debug("Query by adresse IP by date: {}".format(result))

    @mongodb_task(weight=int(DEFAULTS["QUERY_BY_IDENTIFIANT_PERSONNE_90_DAYS"]))
    def query_by_identifiant_personne_90_days(self):
        result = self.collection.find(
            {
                "date": {
                    "$gte": self.random_datetime_within_x_days(90),
                    "$lte": datetime(2023, 1, 1),
                },
                "identifiantPersonne": random.choice(self.unique_id_list),
            }
        )
        logging.debug("Query by identifiant personne 90 days: {}".format(result))
