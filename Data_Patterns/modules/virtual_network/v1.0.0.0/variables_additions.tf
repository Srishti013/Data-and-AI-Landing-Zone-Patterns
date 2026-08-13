# Additional Optional Tags
variable "review_required" {
  type        = string
  description = "(Optional) Is review needed before deletion?"
  default     = ""
}

variable "automation_policy" {
  type        = string
  description = "(Optional) Reference to any automation policy."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window frequency."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Retention period in days (0 = no snapshot)."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox (POC, Training, Demo, R&D)."
  default     = ""
}

variable "service" {
  type        = string
  description = "(Optional) Service component identifier."
  default     = ""
}