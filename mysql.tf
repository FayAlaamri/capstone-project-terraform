resource "alicloud_instance" "mysql" {


  instance_name              = "mysql"
  instance_type              = "ecs.g6.large" 
  system_disk_category       = "cloud_essd"
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  vswitch_id                 = alicloud_vswitch.private-vswitch.id
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"


  availability_zone          = data.alicloud_zones.availability_zones.zones.0.id
  security_groups            = [alicloud_security_group.mysql-sg.id]

  


 
  key_name                   = alicloud_ecs_key_pair.mykey1.key_pair_name


  user_data = base64encode(file("mysql.sh"))

}

output "mysql" {
    value = alicloud_instance.mysql.private_ip
}