########################################################################
# Security Groups
########################################################################

resource "aws_security_group" "all_worker_mgmt_ssh" {
  name_prefix = "all_worker_mgmt_ssh"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

