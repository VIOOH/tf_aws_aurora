resource "aws_security_group" "aurora_security_group" {
  name        = "tf-sg-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  description = "Terraform-managed RDS security group for ${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "tf-sg-rds-${var.name}-${data.aws_vpc.vpc.tags["Name"]}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_sgs" {
  for_each                     = toset(var.allowed_security_groups)
  security_group_id            = aws_security_group.aurora_security_group.id
  referenced_security_group_id = each.value
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "aurora_cidrs" {
  for_each          = toset(var.allowed_cidr)
  security_group_id = aws_security_group.aurora_security_group.id
  cidr_ipv4         = each.value
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}
