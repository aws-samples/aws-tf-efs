data "aws_security_group" "efs_sg" {
  count = var.security_group_tags != null ? 1 : 0

  provider = aws.replica

  tags = var.security_group_tags
}

resource "aws_security_group" "efs_sg" {
  # checkov:skip=CKV2_AWS_5: attached to EFS
  count = var.security_group_tags == null ? 1 : 0

  provider = aws.replica

  name        = "${var.project}-${var.efs_name}-efs-sg"
  description = "Allow inbound traffic from solution servers to EFS"
  vpc_id      = data.aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${var.project}-${var.efs_name}-efs-sg"
    },
    var.tags
  )
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "egress_efs_sg" {
  count = var.security_group_tags == null ? 1 : 0

  provider = aws.replica

  description       = "Allow egress to all from EFS"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_sg[0].id
}
