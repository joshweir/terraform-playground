# resource "aws_iam_policy_attachment" "communicate_josh_attach_policy_sqs_queues" {
#   name    = "communicate__${var.communicate_region}_${var.communicate_environment}_attach_policy_sqs_queues"
#   users = ["${aws_iam_user.communicate_developers.name}"]
#   roles = [
#     "${aws_iam_role.role_for_josh_lambda.name}"
#   ]
#   policy_arn = "${aws_iam_policy.policy_for_sqs_queues.arn}"
# }

