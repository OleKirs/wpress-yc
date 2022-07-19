variable image { default =  "centos-7" }
variable name { default = ""}
variable domain_name { default = ""}
variable fqdn { default = ""}
variable dns_zone_id { default = ""}
variable hostname { default = ""}
variable description { default =  "instance from terraform" }
variable instance_role { default =  "all" }
variable users { default = "centos"}
variable cores { default = ""}
variable platform_id { default = "standard-v1"}
variable memory { default = ""}
variable core_fraction { default = "20"}
variable subnet_id { default = ""}
variable nat { default = "false"}
variable LAN_ip_address { default = ""}
variable WAN_ip_address { default = "" }
variable boot_disk { default =  "network-hdd" }
variable disk_size { default =  "20" }
variable zone { default =  "" }
variable folder_id { default =  "" }
variable metadata { default = "" }
variable preemptible { default = false }

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

data "yandex_compute_image" "image" {
  family = var.image
}

resource "yandex_compute_instance" "instance" {

  name        = var.name
  hostname    = var.hostname
#  fqdn        = var.fqdn

  platform_id = var.platform_id
  description = var.description
  zone        = var.zone
  folder_id   = var.folder_id

  resources {
    cores     = var.cores
    memory    = var.memory
    core_fraction = var.core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type     = var.boot_disk
      size     = var.disk_size
    }
  }
  network_interface {
    subnet_id      = var.subnet_id
    ip_address     = var.LAN_ip_address
    nat            = var.nat
    nat_ip_address = var.WAN_ip_address
  }

  metadata = var.metadata
}

resource "yandex_dns_recordset" "rs2" {

  zone_id = var.dns_zone_id

#  name    = toset(tostring("${var.fqdn}"))
#  name    = "${var.name}.${var.domain_name}."
  name    = "${var.name}"

  type    = "A"
  ttl     = 200
  data    = [var.LAN_ip_address]

}
