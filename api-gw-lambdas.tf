locals {
  api_gateway_path = "${aws_api_gateway_rest_api.communicate_josh_api.id}/*/POST/public/*"
}

resource "aws_lambda_function" "josh_lambda" {
  lifecycle {
    ignore_changes = ["environment", "filename", "last_modified"]
  }

  filename      = "hello-world.zip"
  function_name = "Communicate_Josh_Lambda"
  # commented out the below line as i have modified the lambda on the server and dont wanna overwrite with hello_world
  #source_code_hash = "${base64sha256(file("hello-world.zip"))}"
  role          = "${aws_iam_role.role_for_josh_lambda.arn}"
  handler       = "bundle.handler"
  runtime       = "nodejs8.10"
  timeout       = 30

  memory_size   = "128"
}

resource "aws_iam_role" "role_for_josh_lambda" {
  name = "Communicate_role_josh_lambda"

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

data "aws_iam_policy_document" "policy_for_josh_lambda" {
  statement {
    sid = "CreateLogGroups"
    actions = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${var.aws_region}:${var.smokeball_aws_account}:*"]
  }
  statement {
    sid = "CreateLogStreams"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.aws_region}:${var.smokeball_aws_account}:log-group:/aws/lambda/${aws_lambda_function.josh_lambda.function_name}:*"]
  }
  statement {
    sid = "EC2Interfaces"
    actions = ["ec2:CreateNetworkInterface","ec2:DescribeNetworkInterfaces","ec2:DetachNetworkInterface","ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "logging_for_notify_lambda" {
  name = "/aws/lambda/${aws_lambda_function.josh_lambda.function_name}"
}

resource "aws_iam_role_policy" "policy_for_josh_lambda" {
  name = "Communicate_policy_josh"
  role = "${aws_iam_role.role_for_josh_lambda.id}"

  policy = "${data.aws_iam_policy_document.policy_for_josh_lambda.json}"
}

resource "aws_lambda_permission" "allow_apig_call_josh_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.josh_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.smokeball_aws_account}:${aws_api_gateway_rest_api.communicate_josh_api.id}/*/POST/public/*"
}

resource "aws_lambda_permission" "allow_apig_call_josh_lambda_get" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.josh_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.smokeball_aws_account}:${aws_api_gateway_rest_api.communicate_josh_api.id}/*/GET/public/*"
}
