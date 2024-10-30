data "alicloud_zones" "availability_zones" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

# Create a new ECS instance for VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "vpc"
  cidr_block = "10.0.0.0/16"
}

resource "alicloud_vswitch" "public-vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.1.0/24"
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
  vswitch_name = "public-vswitch"
}

resource "alicloud_vswitch" "public-vswitch-b" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.3.0/24"
  zone_id      = data.alicloud_zones.availability_zones.zones.1.id
  vswitch_name = "public-vswitch-b"
}

resource "alicloud_vswitch" "private-vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.2.0/24"
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
  vswitch_name = "private-vswitch"
}





#---------------NAT

resource "alicloud_nat_gateway" "NAT_gateway" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "http"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public-vswitch.id
  nat_type         = "Enhanced"
}


resource "alicloud_eip_address" "nat" {
  description          = "nat eip"
  address_name         = "nat"
  netmode              = "public"
  bandwidth            = "100"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}


resource "alicloud_eip_association" "nat-association" {
  allocation_id = alicloud_eip_address.nat.id
  instance_id   = alicloud_nat_gateway.NAT_gateway.id
  instance_type = "Nat"
}

# Defines an SNAT rule, allowing instances in the private VSwitch to use the NAT gateway’s public IP for outgoing internet traffic.
resource "alicloud_snat_entry" "http_private" {
  snat_table_id     = alicloud_nat_gateway.NAT_gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private-vswitch.id
  snat_ip           = alicloud_eip_address.nat.ip_address
}



# Creates a route table specifically for private VSwitch traffic.

resource "alicloud_route_table" "table" {
  description      = "Private"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "table-private"
  associate_type   = "VSwitch"
}

# Adds a route to the private route table, directing all outgoing traffic (0.0.0.0/0) to the NAT gateway.

resource "alicloud_route_entry" "nat" {
  route_table_id        = alicloud_route_table.table.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.NAT_gateway.id
}


#Associates the custom route table with the private VSwitch, ensuring that all traffic from this VSwitch follows the route entries defined in the private route table.
resource "alicloud_route_table_attachment" "table_attachment" {
  vswitch_id     = alicloud_vswitch.private-vswitch.id
  route_table_id = alicloud_route_table.table.id
}


