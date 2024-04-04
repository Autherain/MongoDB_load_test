## Peuplement : exécution de locust dans k3s pour mongodb 

Ce dossier spécifiquement permet de peupler la BDD jusqu'à une limite définit en MegaBytes. Vous pourrez ajuster cela dans `settings.py`. Le code est présent dans `mongo_populating.py`.

### Base image

La même image de base peut être utilisée à la fois pour les pods maîtres et pour les travailleurs. La charge de travail réelle, définie dans `mongo_populating.py`, peut être injectée dans les pods en utilisant un configmap. L'image a déjà été construite et rendue publiquement disponible pour votre utilisation. Vous êtes actuellement limité à l'utilisation des dépendances déjà définies dans le projet et les tests ne peuvent être définis que dans `mongo_populating.py`. Vous pouvez construire votre propre image de base si vous avez besoin d'autres dépendances ou de fichiers supplémentaires.

### Deployment workflow

Avant de déployer votre charge de travail locust dans k3s, assurez-vous que votre cluster est accessible via kubectl.

Définissez votre charge de travail dans `mongo_populating.py` et testez en mode autonome localement. Définissez l'URL du CLUSTER dans settings.yaml. Vous pouvez déployer la configuration distribuée dans votre cluster Kubernetes en utilisant la commande suivante :

```shell
cd ..
./redeploy_populate.sh
```

Ce script déploiera un seul pod avec un maître Locust et un déploiement avec trois workers. Tous les objets seront déployés dans votre namespace actuel ou par défaut.

Vous pouvez également remplacer les poids des tâches dans le worker-deployment.yaml si nécessaire. Assurez-vous de redéployer les objets après avoir modifié les poids.

### Démarrage de la charge de travail

Nous vous invitons à utiliser un `ssh tunnel`afin de pouvoir faire parvenir les données de votre noeud maitre sur votre machine en local. Utilisez le script `../ssh_tunnel_easy.sh` pour faire cela.

La commande suivante peut être utilisée pour rediriger le port 8089 du service maître vers votre localhost. Cela évite la nécessité d'exposer votre service maître à l'internet public :

```shell
kubectl port-forward service/master 8089:8089
```

Veuillez laisser le terminal ouvert pendant le temps où vous travaillez avec Locust. L'interface graphique peut être accédée en naviguant vers http://localhost:8089.

### Scaling the workers

Les travailleurs peuvent être mis à l'échelle vers le haut ou vers le bas en utilisant la commande suivante :

```shell
kubectl scale deployment locust-worker-deployment --replicas 10
```

Le paramètre --replicas spécifie le nombre d'instances de travailleur souhaitées. Kubernetes répartira automatiquement les pods des travailleurs entre tous les nœuds disponibles dans le cluster. Assurez-vous de mettre à l'échelle vos groupes de nœuds en conséquence avant d'exécuter cette commande.

