data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier            = "tf-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  availability_zones            = var.azs
  database_name                 = var.database_name
  master_username               = var.master_username
  manage_master_user_password   = var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_password               = !var.manage_master_user_password ? var.master_password : null
  engine                        = var.engine
  engine_version                  = var.engine_version
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  vpc_security_group_ids          = [aws_security_group.aurora_security_group.id]
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = aws_kms_key.aurora.arn
  apply_immediately               = var.apply_immediately
  db_subnet_group_name            = aws_db_subnet_group.aurora_subnet_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.id
  final_snapshot_identifier       = "final-snapshot-${var.name}-${data.aws_vpc.vpc.tags["Name"]}" # Useful in dev
  backtrack_window                = var.target_backtrack_window
  tags = merge(
    {
      "Name" = "tf-rds-aurora-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
    },
    var.tags,
  )

  #skip_final_snapshot                 = true # Useful in dev - defaults to false
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  lifecycle {
    prevent_destroy = "true" # https://www.terraform.io/docs/configuration/resources.html#prevent_destroy
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count      = var.cluster_size
  identifier = "tf-rds-aurora-${var.name}-${data.aws_vpc.vpc.tags["Name"]}-${count.index}"
  engine     = var.engine
  #engine_version          = var.engine_version
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.instance_class
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.id
  db_parameter_group_name      = aws_db_parameter_group.aurora_parameter_group.id
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = aws_iam_role.aurora_instance_role.arn
  monitoring_interval          = 5
  ca_cert_identifier           = var.ca_cert_identifier
  performance_insights_enabled = var.performance_insights_enabled
  tags = merge(
    {
      "Name" = "tf-rds-aurora-${var.name}-${data.aws_vpc.vpc.tags["Name"]}-${count.index}"
    },
    var.tags,
  )
}

resource "aws_rds_cluster_instance" "aurora_instance_read_replica" {
  count      = var.read_replica_count
  identifier = "tf-rds-aurora-${var.name}-${data.aws_vpc.vpc.tags["Name"]}-read-replica-${count.index}"
  engine     = var.engine
  #engine_version          = var.engine_version
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.read_replica_instance_class
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.id
  db_parameter_group_name      = aws_db_parameter_group.aurora_parameter_group.id
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = aws_iam_role.aurora_instance_role.arn
  monitoring_interval          = 5
  ca_cert_identifier           = var.ca_cert_identifier
  performance_insights_enabled = var.performance_insights_enabled_rr
  tags = merge(
    {
      "Name" = "tf-rds-aurora-${var.name}-${data.aws_vpc.vpc.tags["Name"]}-read-replica-${count.index}"
    },
    var.tags,
  )
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  subnet_ids = var.subnets
  tags = merge(
    {
      "Name" = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
    },
    var.tags,
  )
}

resource "aws_db_parameter_group" "aurora_parameter_group" {
  name        = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  family      = var.family
  description = "Terraform-managed parameter group for ${var.name}-${data.aws_vpc.vpc.tags["Name"]}"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
  tags = merge(
    {
      "Name" = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
    },
    var.tags,
  )
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name        = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  family      = var.family
  description = "Terraform-managed cluster parameter group for ${var.name}-${data.aws_vpc.vpc.tags["Name"]}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
  tags = merge(
    {
      "Name" = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
    },
    var.tags,
  )
}

resource "aws_db_option_group" "aurora_option_group" {
  name                     = "tf-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  option_group_description = "Terraform-managed option group for ${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
}

data "aws_iam_policy_document" "aurora_instance_monitoring_policy" {
  statement {
    sid    = "monitoringAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aurora_instance_role" {
  name               = "tf-role-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  assume_role_policy = data.aws_iam_policy_document.aurora_instance_monitoring_policy.json
  path               = "/tf/${var.env}/${var.name}-${data.aws_vpc.vpc.tags["Name"]}/" # edits?
}

resource "aws_iam_role_policy_attachment" "aurora_policy_rds_monitoring" {
  role       = aws_iam_role.aurora_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

################################################################################
# Managed Secret Rotation for master password
################################################################################

resource "aws_secretsmanager_secret_rotation" "master_password" {
  count = var.manage_master_user_password && var.manage_master_user_password_rotation ? 1 : 0

  secret_id          = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
  rotate_immediately = var.master_user_password_rotate_immediately

  rotation_rules {
    automatically_after_days = var.master_user_password_rotation_automatically_after_days
    duration                 = var.master_user_password_rotation_duration
    schedule_expression      = var.master_user_password_rotation_schedule_expression
  }
}
