
resource "alicloud_ecs_key_pair" "mykey1" {
  key_pair_name = "mykey1"
  key_file      = "capstone-key1.pem"
}
