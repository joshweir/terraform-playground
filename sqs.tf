# data "aws_iam_policy_document" "policy_for_sqs_queues" {
#   statement {
#     sid = "SNS"
#     effect = "Allow"
#     actions = ["sqs:*"]
#     resources = ["*"]
#   }
# }
# resource "aws_iam_policy" "policy_for_sqs_queues" {
#   name = "communicate_josh_sqs_queues"

#   policy = "${data.aws_iam_policy_document.policy_for_sqs_queues.json}"
# }

# resource "aws_sqs_queue" "josh_sqs_dlq" {
#   name                      = "communicate-${upper(var.communicate_environment)}-josh-dlq"
#   message_retention_seconds = 1209600
# }

# resource "aws_sqs_queue" "josh_sqs" {
#   name                      = "communicate-${upper(var.communicate_environment)}-josh"
#   receive_wait_time_seconds = 20
#   redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.josh_sqs_dlq.arn}\",\"maxReceiveCount\":10}"
# }

# data "aws_iam_policy_document" "policy_for_josh_sqs" {
#   statement {
#     sid = "SQS"
#     effect = "Allow"
#     actions = ["sqs:*"]
#     resources = ["${aws_sqs_queue.josh_sqs.arn}"]
#   }
# }
