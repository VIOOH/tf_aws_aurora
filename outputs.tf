output "rds_cluster_id" {
  value = aws_rds_cluster.aurora.id
}

output "writer_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}

output "security_group_id" {
  value = aws_security_group.aurora_security_group.id
}

output "cluster_arn" {
  value = aws_rds_cluster.aurora.arn
}

output "aurora_kms_key" {
  value = aws_kms_key.aurora.arn
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = try(aws_rds_cluster.aurora.master_user_secret, null)
}

output "db_cluster_secretsmanager_secret_rotation_enabled" {
  description = "Specifies whether automatic rotation is enabled for the secret"
  value       = try(aws_secretsmanager_secret_rotation.master_password[0].rotation_enabled, null)
}
