locals {
  prefix = "dev_au"
}

resource "aws_lambda_function" "dlq_restore_item_lambda" {
  lifecycle {
    ignore_changes = ["environment", "filename", "last_modified"]
  }

  filename      = "communicate-dlq-restore-item-lambda-package.zip"
  source_code_hash = "${base64sha256(file("communicate-dlq-restore-item-lambda-package.zip"))}"
  function_name = "Communicate_Application_Dlq_Restore_Item_${local.prefix}"
  role          = "${aws_iam_role.dlq_restore_item_lambda.arn}"
  handler       = "bundle.handler"
  runtime       = "nodejs8.10"
  timeout       = 300
  memory_size   = "128"
}

resource "aws_iam_role" "dlq_restore_item_lambda" {
  name = "Communicate-Dlq-Restore-Item-lambda-role-${local.prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id   = "AllowExecutionFromCloudWatch"
#   action         = "lambda:InvokeFunction"
#   function_name  = "${aws_lambda_function.dlq_restore_item_lambda.function_name}"
#   principal      = "logs.${var.aws_region}.amazonaws.com"
# }

# resource "aws_cloudwatch_log_group" "logging_for_dlq_restore_item_lambda" {
#   name = "/aws/lambda/${aws_lambda_function.dlq_restore_item_lambda.function_name}"
# }

# resource "aws_cloudwatch_log_subscription_filter" "dlq_restore_item_lambda" {
#   name            = "Communicate_Application_Dlq_Restore_Item_${local.prefix}_logfilter"
#   log_group_name  = "${aws_cloudwatch_log_group.logging_for_dlq_restore_item_lambda.name}"
#   filter_pattern  = "[timestamp=*Z, request_id=\"*-*\", event]"
#   destination_arn = "${aws_lambda_function.logentries_lambda.arn}"
# }

data "aws_iam_policy_document" "policy_for_dlq_restore_item_lambda" {
  statement {
    sid = "CreateLogGroups"
    actions = ["logs:*"]
    resources = ["*"]
  }
  statement {
    sid = "ExecuteLambda"
    actions = ["lambda:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "policy_for_dlq_restore_item_lambda" {
  name = "Communicate-Dlq-Restore-Item-lambda-Policy-${local.prefix}"
  role = "${aws_iam_role.dlq_restore_item_lambda.id}"

  policy = "${data.aws_iam_policy_document.policy_for_dlq_restore_item_lambda.json}"
}
