variable "role_assignments" {
  type        = any
  description = "Account identity role assignments."
  default     = {}
}

variable "cosmos_role_assignments" {
  type        = any
  description = "Account identity Cosmos DB SQL role assignments."
  default     = {}
}

variable "project_role_assignments" {
  type        = any
  description = "Project identity role assignments (before capability host)."
  default     = {}
}

variable "wait_after_role_assignments" {
  type        = string
  description = "Duration to wait after role assignments for RBAC propagation."
  default     = "60s"
}
