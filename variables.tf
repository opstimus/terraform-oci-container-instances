variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "name" {
  description = "The name of the resource."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where the instance will be created."
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the VCN where the NSG will be created."
  type        = string
}

variable "nsg_ingress_rules" {
  type = map(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    port_min    = optional(number, null)
    port_max    = optional(number, null)
    description = optional(string, "")
  }))
  description = "A map of ingress rules to create in the NSG. The key is a unique identifier for each rule."
  default     = {}
  validation {
    condition = alltrue([
      for rule in values(var.nsg_ingress_rules) :
      (rule.port_min == null) == (rule.port_max == null)
    ])
    error_message = "Each ingress rule must specify both port_min and port_max, or neither."
  }
}

variable "availability_domain" {
  description = "The availability domain where the instance will be created."
  type        = string
}

variable "shape" {
  description = "The shape of the instance (e.g., VM.Standard.E4.Flex)."
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet where the instance will be created."
  type        = string
}

variable "ocpus" {
  description = "The number of OCPUs to allocate to the instance (applicable for flexible shapes)."
  type        = number
}

variable "memory_in_gbs" {
  description = "The amount of memory in GBs to allocate to the instance (applicable for flexible shapes)."
  type        = number
}

variable "containers" {
  description = "Map of containers to run in the instance. The key is used as the container display_name if none is provided."
  type = map(object({
    image_url             = string
    display_name          = optional(string, null)
    arguments             = optional(list(string), null)
    command               = optional(list(string), null)
    environment_variables = optional(map(string), {})
  }))
  validation {
    condition     = length(var.containers) >= 1
    error_message = "At least one container must be specified."
  }
}

variable "image_pull_secrets" {
  description = "Map of image pull secrets for private container registries. Key is a unique identifier. All fields are required per entry."
  type = map(object({
    registry_endpoint = string
    username          = string
    password          = string
  }))
  default   = {}
  sensitive = true
}

variable "container_restart_policy" {
  description = "The restart policy for the container instance (ALWAYS, NEVER, ON_FAILURE)."
  type        = string
  default     = "ALWAYS"
  validation {
    condition     = contains(["ALWAYS", "NEVER", "ON_FAILURE"], var.container_restart_policy)
    error_message = "container_restart_policy must be one of: ALWAYS, NEVER, ON_FAILURE."
  }
}

variable "is_public_ip_assigned" {
  description = "Whether to assign a public IP to the container instance VNIC."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Free-form tags to apply to the instance resources."
  type        = map(string)
  default     = null
}
