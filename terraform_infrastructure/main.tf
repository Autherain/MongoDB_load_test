# ------------------------------------------------------------------------------
# main.tf
# Ce document est le plan principal de la pile terraform, celui ou les
# ressources vont être déclarées. L'acronyme "dtt" utilisé dans la nomenclature
# signifie "delight technical test".
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# PROVIDERS
# Cette section décris les providers utilisés - des plugins utilisés pour gérer 
# les ressources.
# ------------------------------------------------------------------------------

terraform {
  required_providers {

    # Le test portant sur aws, on signifie à Terraform que l'on va utliser le
    # plug-in aws maintenu par Hashicorp (société propriétaire de Terraform)
    aws = {
      source  = "hashicorp/aws" 
      version = "~> 5.0"
    }
  }
}

# Configuration du provider AWS.
provider "aws" {
  # Ici est définie la région AWS (zone géographique) ou sont rassemblés les 
  # services et serveurs qui vont être utilisés. Les régions AWS sont
  # indépendantes et seuls quelques services (S3 par exemple) sont tranverses.
  region = "${var.dtt_region}"
}

# ------------------------------------------------------------------------------
# VPC
# Dans cette section les virtual personnal cloud seront déclarés. Ce sont des
# réseaux virtuels au sein des régions AWS au sein desquels vont communiquer
# nos autres ressources de compute ou de stockage.
# ------------------------------------------------------------------------------

# Le VPC lui même. Il contiendra les sous-réseaux (subnets).
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "dtt_vpc" {

  # Le block CIDR indique l'IPV4 du réseau ainsi que la plage utlisable.
  cidr_block          = "${var.dtt_vpc_cidr_block}"

  # Selon si l'on souhaite faire tourner les instances EC2 associées sur des
  # tenants dédiés ou non.
  instance_tenancy    = "${var.dtt_vpc_instance_tenancy}"

  # Si l'on souhaite que le VPC supporte le DNS & que les hostnames puissent
  # être utilisés
  enable_dns_support   = var.dtt_vpc_dns_support
  enable_dns_hostnames = var.dtt_vpc_dns_hostnames

  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "dtt-vpc",
    "environment"       = "${var.dtt_environment_tag}"
  }
}

# ------------------------------------------------------------------------------
# EC2
# Dans cette section sont déclarées les ressources utilisées pour les serveurs
# ------------------------------------------------------------------------------

# Le sous réseau public du VPC qui contient la ressource de compute (instance EC2)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "dtt_subnets_public_ec2" {

  # Pour chaque clé de la variable on crée un sous-réseau
  for_each = var.dtt_compute_availability_zones_parameters

  # L'identifiant unique du VPC Hôte du sous réseau
  vpc_id                = aws_vpc.dtt_vpc.id

  # La plage sur laquelle le sous réseau s'étend
  cidr_block            = "${each.value.cidr_block}"

  # C'est un réseau public donc le sous réseau doit se voir assigner une IP
  # publique
  map_public_ip_on_launch = true

  # Dans quelle zone de disponibilité de la région ce sous réseau doit-il
  # se trouver.
  availability_zone     = "${each.key}"

  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "dtt-subnet-public-compute-${each.key}"
    environment         = "${var.dtt_environment_tag}"
    exposition          = "public"
  }
}

# Table de routage qui sera utilisée dans le sous-réseau public des EC2.
# Le sujet ne précise pas de règles de sortie depuis le sous-réseau donc
# aucune n'est ajoutée. En conséquence, aucun traffic sortant ne sera 
# routé en dehors du VPC.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "dtt_route_public_ec2" {

  # Le vpc qui acceuillera la table de routage
  vpc_id = aws_vpc.dtt_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dtt-internet-gw.id
  }

  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "dtt-route-public-compute"
    environment         = "${var.dtt_environment_tag}"
    exposition          = "public"
  }  
}

# Associe la table de routage publique EC2 avec le sous-réseau cible.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "dtt_subnet_route_association_public_ec2" {

  # On itère sur chaque sous-réseau privé utilisé pour acceuillir la base de
  # donnée.
  for_each       = aws_subnet.dtt_subnets_public_ec2

  # L'identifiant du sous réseau à associer : le sous-réseau public compute
  subnet_id      = each.value.id

  # L'identifiant de la table de routage à associer
  route_table_id = aws_route_table.dtt_route_public_ec2.id
}

# Récupération de la clé publique SSH afin de la disposer ultérieurement dans
# une instance où l'on souhaitera pouvoir se connecter en SSH.
resource "aws_key_pair" "dtt_key_compute" {
  key_name    = "dtt-key-compute"
  public_key  = file("dtt_compute_key.pub")  
}

# Cartes réseaux virtuelles des instances EC2. Cela nous permet de contrôler
# les adresses des machines pour une utilisation future
resource "aws_network_interface" "dtt_compute_instances_network_interfaces" {
  
  # On itère sur chaque instance définie dans les paramètres (1 pour l'exemple)
  for_each       = var.dtt_compute_instances_parameters

  # Dans quel sous-réseau elle prend place
  subnet_id   = aws_subnet.dtt_subnets_public_ec2[each.value.availability_zone].id

  # Quelle est l'adresse IP à utiliser
  private_ips = ["${each.value.private_ip}"]

  # security_groups = [aws_security_group.dtt_allow_ssh_in.id, aws_security_group.dtt_allow_traffic_out.id, aws_security_group.dtt_allow_ping_in.id,aws_security_group.k3s_supervisor_and_kubernetes_api_server.id,aws_security_group.kubelet_metric.id]
  security_groups = [aws_security_group.dtt_allow_ssh_in.id, aws_security_group.dtt_allow_traffic_out.id,aws_security_group.allow_all_inside.id]

  tags = {
    Name                = "dtt-network-interface-${each.key}"
    exposition          = "public"
  }
}

# Instances EC2 de calcul, le "serveur" de l'exercice.Une seule machine est
# configurée dans les paramètres donc une seule instance sera initiée. 
resource "aws_instance" "dtt_compute_instances" {

  # On itère sur chaque instance définie dans les paramètres (1 pour l'exemple)
  for_each       = var.dtt_compute_instances_parameters

  # Image machine à utiliser
  ami           = data.aws_ami.dtt_ami_al2023.id

  # Format d'instance à utiliser
  instance_type = "${each.value.type}"

  # L'identifiant du sous réseau public à associer à l'instance, on récupère celui
  # associé à la zone de disponibilité.
  # subnet_id     = aws_subnet.dtt_subnets_public_ec2[each.value.availability_zone].id

  # Interface réseau à attribuer à cette instance. On utilise celle précédemment
  # créée
  network_interface {
    network_interface_id = aws_network_interface.dtt_compute_instances_network_interfaces[each.key].id
    device_index         = 0
  }

  # La clé ssh à utiliser pour se connecter à l'instance
  key_name      = aws_key_pair.dtt_key_compute.key_name

  tags = {
    Name = "${each.key}"
  }
}

# Passerelle permettant à l'instance EC2 de communiquer avec avec internet. Utile
# pour récupérer le client Postgresql afin de communiquer avec le serveur de BDD
resource "aws_internet_gateway" "dtt-internet-gw" {
  vpc_id = aws_vpc.dtt_vpc.id

  tags = {
    Name = "main"
  }
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# Dans cette section sont déclarées les groupes et règles de sécurité
# ------------------------------------------------------------------------------

# Règle de filtrage permettant le passage des paquets sur le port 22 entrant
# afin d'autoriser les connexions SSH entrantes.
resource "aws_security_group" "dtt_allow_ssh_in" {

  # Nom de la règle
  name        = "dtt-allow-ssh-in"

  # VPC acceuillant la règle 
  vpc_id      = aws_vpc.dtt_vpc.id

  # Flux entrant avec ses caractéristiques (ports, protocole concerné, plage
  # d'adresses concernées par la règle...). Ici on autorise la connexion depuis
  # n'importe quelle adresse IP
  ingress {
    description      = "SSH from VPC"
    from_port        = 22 
    to_port          = 22 
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "dtt-allow-ssh-in"
    environment         = "${var.dtt_environment_tag}"
  }
}

# Règle de filtrage permettant la communication sortante vers le port 5432 
# utilisé par la BDD. 
resource "aws_security_group" "dtt_allow_traffic_out" {

  # Nom de la règle
  name        = "dtt-allow-traffic-out"

  # VPC acceuillant la règle 
  vpc_id      = aws_vpc.dtt_vpc.id

  # Permet les flux sortants de la machine (À restreindre selon les besoins
  # effectifs)
  egress {
    description      = "Allow outgoing traffic"
    from_port        = 0 
    to_port          = 0 
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "dtt-allow-traffic-out"
    environment         = "${var.dtt_environment_tag}"
  }
}

resource "aws_security_group" "allow_all_inside" {

  # Nom de la règle
  name        = "allow-all-inside"

  # VPC acceuillant la règle 
  vpc_id      = aws_vpc.dtt_vpc.id

  # Permet les flux sortants de la machine (À restreindre selon les besoins
  # effectifs)
  ingress {
    description      = "allow-all-inside"
    from_port        = 0 
    to_port          = 0 
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.dtt_vpc.cidr_block]
  }

  # Les étiquettes utilisées pour classer les ressources ou indentifier des
  # groupes de ressources définies
  tags = {
    Name                = "allow-all-inside"
    environment         = "${var.dtt_environment_tag}"
  }
}


# resource "aws_security_group" "dtt_allow_ping_in" {
#   name        = "dtt-allow-ping-in"
#   vpc_id      = aws_vpc.dtt_vpc.id
#
#   ingress {
#     description      = "ICMP from VPC"
#     from_port        = -1  # ICMP protocol does not use ports, so set to -1
#     to_port          = -1  # ICMP protocol does not use ports, so set to -1
#     protocol         = "icmp"
#     cidr_blocks      = [aws_vpc.dtt_vpc.cidr_block]
#   }
#
#   tags = {
#     Name        = "dtt-allow-ping-in"
#     environment = var.dtt_environment_tag
#   }
# }
#
# resource "aws_security_group" "k3s_supervisor_and_kubernetes_api_server" {
#   name = "dtt-allow-k3s-supervisor-and-kubernetes-api-server"
#   vpc_id = aws_vpc.dtt_vpc.id
#
#   ingress {
#     description      = "k3s-supervisor-kubernets-api-server"
#     from_port        = 6443 # ICMP protocol does not use ports, so set to -1
#     to_port          = 6443  # ICMP protocol does not use ports, so set to -1
#     protocol         = "tcp"
#     cidr_blocks      = [aws_vpc.dtt_vpc.cidr_block]
#   }
#
#   tags = {
#     Name        = "dtt-allow-k3s-supervisor-kubernets-api-server"
#     environment = var.dtt_environment_tag
#   }
# }
#
# resource "aws_security_group" "kubelet_metric" {
#   name = ""
#   vpc_id = aws_vpc.dtt_vpc.id
#
#   ingress {
#     description      = "kubelet-metric"
#     from_port        = 10250 # ICMP protocol does not use ports, so set to -1
#     to_port          = 10250  # ICMP protocol does not use ports, so set to -1
#     protocol         = "tcp"
#     cidr_blocks      = [aws_vpc.dtt_vpc.cidr_block]
#   }
#
#   tags = {
#     Name        = "dtt-allow-kubelet-metric"
#     environment = var.dtt_environment_tag
#   }
# }
