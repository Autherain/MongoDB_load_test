
# ------------------------------------------------------------------------------
# GENERAL
# ------------------------------------------------------------------------------

# Ici est définie la région AWS (zone géographique) 
# Pour les besoins de l'exercice, "us-east-1" est utilisée, car c'est la
# seule autorisée sur mon lab. Dans la pratique "eu-west-3", qui correspond
# à la région Europe(Paris) pourrait être proposée pour satisfaire à des
# considérations de stockage de la donnée sur le sol européen et des besoins
# de performances au vu du positionnement géographique de la clientèle.
variable "dtt_region" {
  type        = string
  default     = "us-east-1"
  description = "Defines the AWS region used for the infrastructure"
}

# Tag d'environnement. Permet de tagger les machines pour classer les ressources
# selon leur environnement. Ex : Dev, Qual, Pré-production, Production...
variable "dtt_environment_tag" {
  description = "Defines the environment of the resource"
  default     = "Production"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

# Le block CIDR indique l'IPV4 du réseau ainsi que la plage utlisable.
# La valeur initialement proposée par AWS permet 65 536 IPs, nous conserverons
# cette valeur. 
# - Format : Notation CIDR - XXX.XXX.XXX.XXX/YY où XXX est entre 0 et 255 et YY
# entre 1 et 32
# - Ex: "10.0.0.0/16"
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#cidr_block
variable "dtt_vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Defines the CIDR block used for the VPC declaration"
}

# Ce paramètre est à modifier si l'on souhaite faire tourner les instances
# EC2 associées à ce VPC sur des tenants dédiés. Nous souhaitons conserver
# la valeur par défaut.
# Valeurs : "default" | "dedicated"
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#instance_tenancy
variable "dtt_vpc_instance_tenancy" {
  type        = string
  default     = "default"
  description = "Defines the tenancy of EC2 instances used for the VPC declaration"
}

# Ce paramètre indique si l'on souhaite que notre VPC supporte le DNS.
# Valeurs : true | false
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_support
variable "dtt_vpc_dns_support" {
  type        = bool
  default     = true
  description = "Defines if we want the VPC to support DNS"
}

# Ce paramètre indique si l'on souhaite que notre VPC supporte les noms d'hôtes.
# Valeurs : true | false
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_hostnames
variable "dtt_vpc_dns_hostnames" {
  type        = bool
  default     = true
  description = "Defines if we want the VPC to support DNS hostnames"
}

# ------------------------------------------------------------------------------
# EC2
# ------------------------------------------------------------------------------

# Liste des zone de disponibilités au sein de la region que l'on souhaite
# utiliser. Dans le test, une seule région est définie afin de conserver une
# seule instance des ressources. Si l'on augmente le nombre de zones, les
# ressources vont être réparties sur les différentes zones afin d'assurer la
# résilience du système.
variable "dtt_compute_availability_zones_parameters" {

  # Définition du format de la variable  
  type = map(object({
    cidr_block        = string
  }))
  
  default = {
    "us-east-1a" : {
      cidr_block    = "10.0.1.0/24"
    }
  }

  description = "Defines availability zones and associated paramters used for the compute resource."
}

# Sont regroupées ici les données spécifiques à chaque instance EC2.
# Pour le test, seulement une seule est définie dans le format précisé
# par le sujet. 
# On configure dans quelle zone de disponibilité placer l'instance, son format
# ainsi que son IP privée.
variable "dtt_compute_instances_parameters" {

  # Définition du format de la variable  
  type = map(object({
    availability_zone = string
    type              = string
    private_ip        = string
  }))
  
  default = {
    "mongo-instance-1" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.10"
    },
    "mongo-instance-2" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.11"
    },
    "mongo-instance-3" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.12"
    },
    "mongo-instance-4" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.13"
    },
    "locust-instance-1" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.14"
    },
    "locust-instance-2" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.15"
    },
    "locust-instance-3" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.16"
    },
    "locust-instance-4" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.17"
    },
    "locust-instance-5" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.18"
    },
    "locust-instance-6" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.19"
    },
    "locust-instance-7" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.20"
    },
    "locust-instance-8" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.21"
    },
    "locust-instance-9" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.22"
    },
    "help" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.23"
    },
    "me" : {
      availability_zone = "us-east-1a"
      type              = "t2.medium"
      private_ip        = "10.0.1.24"
    },
  }

  description = "Defines availability zones and associated paramters used for the compute resource."
}

# Image de l'OS qui sera utilisée comme template sur les instances EC2
# Ici on recherche une image ubuntu gratuite éligible au "free tier usage"
# Le test précisant un format d'instance t4g.micro, ces instances sont
# conçues avec des processeurs Graviton2 AWS basés sur Arm. Nous sélectionnons
# donc la version de l'OS correspondante.
data "aws_ami" "dtt_ami_al2023" {
  most_recent = true

  # Filtre les images disponibles selon leur nom, avec le pattern défini
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"]
  }

  # Amazon
  owners = ["099720109477"]
}
