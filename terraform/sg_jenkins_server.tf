# Security Group:
resource "aws_security_group" "jenkins_server_dup" {
  name        = "jenkins_server_dup"
  description = "Jenkins Server: created by Terraform for [default]"

  # legacy name of VPC ID
  vpc_id = "${data.aws_vpc.default_vpc.id}"

#   tags = {
#     Name = "jenkins_server_dup"
#     env  = "dev"
#   }
}

###############################################################################
# ALL INBOUND
###############################################################################

# ssh
resource "aws_security_group_rule" "jenkins_server_dup_from_source_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh to jenkins_server_dup"
}

resource "aws_security_group_rule" "jenkins_server_dup_from_source_ingress_jnlp" {
  type              = "ingress"
  from_port         = 33453
  to_port           = 33453
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "jenkins server JNLP Connection"
}
# web
resource "aws_security_group_rule" "jenkins_server_dup_from_source_ingress_webui" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "jenkins server web"
}


# resource "aws_security_group_rule" "jenkins_server_dup_from_source_ingress_webui_1" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "http"
#   security_group_id = "${aws_security_group.jenkins_server_dup.id}"
#   cidr_blocks       = ["0.0.0.0/0"]
#   description       = "jenkins server web"
# }


# JNLP
# resource "aws_security_group_rule" "jenkins_server_dup_from_source_ingress_jnlp" {
#   type              = "ingress"
#   from_port         = 33453
#   to_port           = 33453
#   protocol          = "tcp"
#   security_group_id = "${aws_security_group.jenkins_server_dup.id}"
#   cidr_blocks       = ["0.0.0.0/0"]
#   description       = "jenkins server JNLP Connection"
# }

resource "aws_security_group_rule" "jenkins_server_dup_outbound_all_80_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

resource "aws_security_group_rule" "jenkins_server_dup_outbound_all_443_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

###############################################################################
# ALL OUTBOUND
###############################################################################

resource "aws_security_group_rule" "jenkins_server_dup_to_other_machines_ssh_0" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers to ssh to other machines"
}
resource "aws_security_group_rule" "jenkins_server_dup_to_other_machines_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers to ssh to other machines"
}

resource "aws_security_group_rule" "jenkins_server_dup_outbound_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

resource "aws_security_group_rule" "jenkins_server_dup_outbound_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = "${aws_security_group.jenkins_server_dup.id}"
  description       = "allow all outbound"
}