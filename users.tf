# resource "aws_iam_user" "communicate_developers" {
#   name = "communicate_${var.communicate_region}_${var.communicate_environment}_developers"
#   path = "/"
# }

# resource "aws_iam_access_key" "communicate_developers" {
#   user = "${aws_iam_user.communicate_developers.name}"
# }

# output "communicate_developers_id" {
#   value = "${aws_iam_access_key.communicate_developers.id}"
# }
# output "communicate_developers_key" {
#   value = "${aws_iam_access_key.communicate_developers.secret}"
# }
