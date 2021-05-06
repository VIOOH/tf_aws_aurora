variable "env" {
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
}

variable "db_port" {
  default = 3306
}

variable "instance_class" {
  description = "Instance class to use when creating RDS cluster"
  default     = "db.t2.medium"
}

variable "publicly_accessible" {
  description = "Should the instance get a public IP address?"
  default     = "false"
}

variable "name" {
  description = "Name for the Redis replication group i.e. cmsCommon"
}

variable "subnets" {
  description = "Subnets to use in creating RDS subnet group (must already exist)"
  type        = list(string)
}

variable "cluster_parameters" {
  description = "A list of cluster parameter maps to apply"
  type        = list
  default     = []
}

variable "db_parameters" {
  description = "A list of db parameter maps to apply"
  type        = list
  default     = []
}

# see aws_rds_cluster documentation for these variables
variable "database_name" {
}

variable "master_username" {
}

variable "master_password" {
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = "30"
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  default     = "01:00-03:00"
}

variable "storage_encrypted" {
  default = true
}

variable "apply_immediately" {
  default = false
}

variable "iam_database_authentication_enabled" {
  default = false
}

variable "major_engine_version" {
  default = "5.6"
}

variable "engine" {
  default = "aurora"
}

variable "family" {
  default = "aurora5.6"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "ca_cert_identifier" {
  default = "rds-ca-2019"
}

variable "tags" {
  description = "tags"
  default     = {}
}

variable "target_backtrack_window" {
  description = "number seconds for target  backtrack time"
  default     = "86400"
}

variable "performance_insights_enabled" {
  description = "performance insights enabled"
  default     = false
}

variable "performance_insights_enabled_rr" {
  description = "performance insights enabled"
  default     = false
}

variable "read_replica_count" {
  description = "read replica count"
  default     = 0
}

variable "read_replica_instance_class" {
  description = "Instance size for read replica"
  default     = "db.t2.medium"
}