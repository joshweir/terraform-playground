# resource "aws_vpc" "data" {
#   cidr_block            = "10.0.0.0/16"
#   enable_dns_hostnames  = "true"

#   lifecycle {
#     ignore_changes = ["cidr_block"]
#   }

#   tags {
#     Name      = "au-VPC"
#     Purpose   = "Internal VPC that holds permanent resources"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = "${aws_vpc.data.id}"

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_subnet" "data-az1" {
#   vpc_id            = "${aws_vpc.data.id}"
#   cidr_block        = "10.0.0.0/22"
#   availability_zone = "ap-southeast-2a"
# }

# resource "aws_route_table_association" "data-az1" {
#   subnet_id      = "${aws_subnet.data-az1.id}"
#   route_table_id = "${aws_route_table.data.id}"
# }

# resource "aws_subnet" "data-az2" {
#   vpc_id            = "${aws_vpc.data.id}"
#   cidr_block        = "10.0.4.0/22"
#   availability_zone = "ap-southeast-2b"
# }

# resource "aws_route_table_association" "data-az2" {
#   subnet_id      = "${aws_subnet.data-az2.id}"
#   route_table_id = "${aws_route_table.data.id}"
# }

# resource "aws_route_table" "data" {
#   vpc_id = "${aws_vpc.data.id}"

#   tags {
#     Name = "josh db route table"
#   }
# }

# resource "aws_route" "default" {
#   route_table_id         = "${aws_route_table.data.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id         = "${aws_internet_gateway.gw.id}"
# }