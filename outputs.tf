output "nsg_id" {
  description = "The OCID of the Network Security Group associated with the instance."
  value       = oci_core_network_security_group.main.id
}

output "container_instance_id" {
  description = "The OCID of the container instance."
  value       = oci_container_instances_container_instance.main.id
}

output "vnic_id" {
  description = "The VNIC ID attached to the container instance."
  value       = oci_container_instances_container_instance.main.vnics[0].vnic_id
}
