resource "aws_rds_cluster" "data" {
  cluster_identifier                  = "josh-comdb"
  // iam_database_authentication_enabled = "true"
  backup_retention_period             = "10"
  preferred_backup_window             = "06:45-07:45"
  engine                              = "aurora"
  engine_version                      = "5.6.10a"
  database_name                       = "comdb"
  master_username                     = "devops"
  master_password                     = "Pa$$w0rD123!" ## password changed by console, best way to secret manage - check password manager for updated password
  db_subnet_group_name                = "${aws_db_subnet_group.data.id}"
  vpc_security_group_ids              = ["${aws_security_group.data.id}"]
  skip_final_snapshot                 = "true"
##
  tags {
    Name            = "dev-au-aurora"
    environment     = "dev"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "josh-comdb-1"
  cluster_identifier = "${aws_rds_cluster.data.id}"
  instance_class     = "db.t2.small"
  publicly_accessible = "true"

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_db_subnet_group" "data" {
  name       = "josh-comdb"
  subnet_ids = ["${aws_subnet.data-az1.id}", "${aws_subnet.data-az2.id}"]

  tags {
    Name = "Joshs DB subnet group"
  }
}

resource "aws_security_group" "data" {
  name              = "josh-comdb-sg"
  description       = "rds security group for josh-comdb-sg"
  # vpc_id            = "${aws_vpc.sb_sydney.id}"

  tags {
    Name            = "josh-comdb-sg"
  }
}

resource "aws_security_group_rule" "data_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.data.id}"
}

resource "aws_security_group_rule" "data_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["203.111.26.254/32"] # ["10.0.0.0/16"]
  security_group_id = "${aws_security_group.data.id}"
}
