output "instance_groups" {
  value =  google_compute_region_instance_group_manager.envoy.instance_group
}