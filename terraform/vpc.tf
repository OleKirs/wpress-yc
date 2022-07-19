locals {
  domain_name = "test.local"
 #VPC vars
  vpc_subnets = {
    stage = [
      {
        v4_cidr_blocks = ["10.1.1.0/24"]
        zone = "ru-central1-a"
      },
      {
        v4_cidr_blocks = ["10.2.2.0/24"]
        zone           = "ru-central1-b"
      }
    ]
    prod = [
      {
        zone           = "ru-central1-a"
        v4_cidr_blocks = ["10.10.0.0/24"]
      },
      {
        zone           = "ru-central1-b"
        v4_cidr_blocks = ["10.20.0.0/24"]
      },
    ]
  }
}

module "vpc" {
#  source  = "hamnsk/vpc/yandex"
#  version = "0.5.0"
  source = "./modules/vpc"
  name = terraform.workspace
  
  description = "managed by terraform"

  create_folder = length(var.folder_id) > 0 ? false : true

  yc_cloud_id = var.cloud_id
  yc_folder_id = var.folder_id

  subnets = local.vpc_subnets[terraform.workspace]
  
  nat_instance = false
  nat_instance_zone = var.region
}
