variable "env" {
  type = string
}

variable "allowed_cidr" {
  type        = list(string)
  default     = ["127.0.0.1/32"]
  description = "A list of Security Group ID's to allow access to."
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of Security Group ID's to allow access to."
}

variable "azs" {
  description = "A list of Availability Zones in the Region"
  type        = list(string)
}

variable "cluster_size" {
  description = "Number of cluster instances to create"
  type        = number
}

variable "db_port" {
  default = 3306
  type    = number
}

variable "instance_class" {
  description = "Instance class to use when creating RDS cluster"
  default     = "db.t2.medium"
  type        = string
}

variable "publicly_accessible" {
  description = "Should the instance get a public IP address?"
  default     = false
  type        = bool
}

variable "name" {
  description = "Name for the Redis replication group i.e. cmsCommon"
  type        = string
}

variable "subnets" {
  description = "Subnets to use in creating RDS subnet group (must already exist)"
  type        = list(string)
}

variable "cluster_parameters" {
  description = "A list of cluster parameter maps to apply"
  type        = list(any)
  default     = []
}

variable "db_parameters" {
  description = "A list of db parameter maps to apply"
  type        = list(any)
  default     = []
}

# see aws_rds_cluster documentation for these variables
variable "database_name" {
  type = string
}

variable "master_username" {
  description = "Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Required unless `manage_master_user_password` is set to `true` or unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 30
  type        = number
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  default     = "01:00-03:00"
  type        = string
}

variable "storage_encrypted" {
  default = true
  type    = bool
}

variable "apply_immediately" {
  default = false
  type    = bool
}

variable "iam_database_authentication_enabled" {
  default = false
  type    = bool
}

variable "major_engine_version" {
  default = "5.6"
  type    = string
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = null
}

variable "engine" {
  default = "aurora"
  type    = string
}

variable "family" {
  default = "aurora5.6"
  type    = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ca_cert_identifier" {
  default = "rds-ca-2019"
  type    = string
}

variable "tags" {
  description = "tags"
  default     = {}
  type        = map(string)
}

variable "target_backtrack_window" {
  description = "number seconds for target  backtrack time"
  default     = 86400
  type        = number
}

variable "performance_insights_enabled" {
  description = "performance insights enabled"
  default     = false
  type        = bool
}

variable "performance_insights_enabled_rr" {
  description = "performance insights enabled"
  default     = false
  type        = bool
}

variable "read_replica_count" {
  description = "read replica count"
  default     = 0
  type        = number
}

variable "read_replica_instance_class" {
  description = "Instance size for read replica"
  default     = "db.t2.medium"
  type        = string
}
