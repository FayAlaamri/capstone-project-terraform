resource "alicloud_instance" "redis" {


  instance_name              = "redis"
  instance_type              = "ecs.g6.large" 
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  host_name = "redis"
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  vswitch_id                 = alicloud_vswitch.private-vswitch.id
  internet_max_bandwidth_out = 0
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"


  availability_zone          = data.alicloud_zones.availability_zones.zones.0.id
  security_groups            = [alicloud_security_group.redis.id]

  


 
  key_name                   = alicloud_ecs_key_pair.mykey1.key_pair_name


  user_data = base64encode(file("redis-setup.sh"))

}

output "redis_server_private_ip" {
  value = alicloud_instance.redis.private_ip
}