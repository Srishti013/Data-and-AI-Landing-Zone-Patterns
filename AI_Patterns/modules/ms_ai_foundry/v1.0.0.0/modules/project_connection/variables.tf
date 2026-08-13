variable "project_ids" {
  type        = map(string)
  description = "Map of project_key => project ARM id (for same-stack parent resolution)."
  default     = {}
}

variable "ai_foundry_project_connections" {
  type        = any
  description = "Map of project connections to create."
  default     = {}
}
