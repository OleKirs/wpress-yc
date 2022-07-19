# Create VPC infrastructure

resource "yandex_resourcemanager_folder" "folder" {
  count = var.create_folder ? 1 : 0
  cloud_id = var.yc_cloud_id
  name = terraform.workspace
  description = "terraform managed"
}

resource "yandex_vpc_network" "this" {
  name        = var.name
  description = "${var.description} ${var.name} network"
  folder_id   = var.create_folder ? yandex_resourcemanager_folder.folder[0].id : var.yc_folder_id

  labels = var.labels
  depends_on = [
    yandex_resourcemanager_folder.folder
  ]
}

resource "yandex_dns_zone" "test_local" {
  name        = "test-local"
  description = "Test.local DNS zone"

  zone             = "test.local."
  public           = false
  private_networks = [yandex_vpc_network.this.id]
  
  depends_on = [
    yandex_vpc_network.this
  ]
}

resource "yandex_vpc_route_table" "rt-inet" {
  count = 1
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "10.1.1.5"
  }

  depends_on = [
    yandex_vpc_network.this
  ]
}

resource "yandex_vpc_subnet" "this" {
  for_each       = {for z in var.subnets : z.zone => z}
  name           = "${var.name}-${each.value.zone}"
  description    = "${var.description} ${var.name} subnet for zone ${each.value.zone}"
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  network_id     = yandex_vpc_network.this.id
  labels         = var.labels
  folder_id      = var.create_folder ? yandex_resourcemanager_folder.folder[0].id : var.yc_folder_id

  route_table_id = yandex_vpc_route_table.rt-inet[0].id

  depends_on = [
    yandex_vpc_network.this,
    yandex_vpc_route_table.rt-inet
  ]
}

