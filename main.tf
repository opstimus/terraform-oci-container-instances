resource "oci_core_network_security_group" "main" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.project}-${var.environment}-${var.name}"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "instance_ingress" {
  for_each                  = var.nsg_ingress_rules
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = each.value.protocol
  source                    = each.value.source
  source_type               = each.value.source_type
  description               = each.value.description
  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" && each.value.port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.port_min
        max = each.value.port_max
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" && each.value.port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.port_min
        max = each.value.port_max
      }
    }
  }

}

resource "oci_core_network_security_group_security_rule" "instance_egress" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all outbound traffic"
}

resource "oci_container_instances_container_instance" "main" {
  availability_domain      = var.availability_domain
  compartment_id           = var.compartment_id
  display_name             = "${var.project}-${var.environment}-${var.name}"
  container_restart_policy = var.container_restart_policy
  shape                    = var.shape
  freeform_tags            = var.tags

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  dynamic "containers" {
    for_each = var.containers
    content {
      image_url             = containers.value.image_url
      arguments             = containers.value.arguments
      command               = containers.value.command
      display_name          = coalesce(containers.value.display_name, containers.key)
      environment_variables = containers.value.environment_variables
      freeform_tags         = var.tags
    }
  }

  dynamic "image_pull_secrets" {
    for_each = var.image_pull_secrets
    content {
      registry_endpoint = image_pull_secrets.value.registry_endpoint
      secret_type       = "BASIC"
      username          = image_pull_secrets.value.username
      password          = image_pull_secrets.value.password
    }
  }

  vnics {
    subnet_id             = var.subnet_id
    display_name          = "${var.project}-${var.environment}-${var.name}"
    is_public_ip_assigned = var.is_public_ip_assigned
    nsg_ids               = [oci_core_network_security_group.main.id]
  }
}

data "oci_core_vnic" "main" {
  vnic_id = oci_container_instances_container_instance.main.vnics[0].vnic_id
}
