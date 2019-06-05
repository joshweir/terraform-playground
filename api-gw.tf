locals {
  api_gw_hostname = "${replace("${aws_api_gateway_deployment.communicate_josh_api_apig_deployment.invoke_url}", "/^https?://([^/]+)/.*$/", "$1")}"
}

resource "aws_api_gateway_deployment" "communicate_josh_api_apig_deployment" {
  rest_api_id       = "${aws_api_gateway_rest_api.communicate_josh_api.id}"
  stage_name        = "v1"
  stage_description = "${md5(file("api-gw.tf"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_rest_api" "communicate_josh_api" {
  name        = "communicate_josh_api"
  description = "API gateway for josh testing"

  body = <<EOF
swagger: "2.0"
info:
  title: "communicate_josh_api"
  version: v1
schemes: 
- "https"
paths:
  /public/josh:
    x-amazon-apigateway-any-method:
      produces:
      - "application/json"
      responses:
        200:
          description: "200 response"
          schema:
            $ref: "#/definitions/Empty"
      x-amazon-apigateway-integration:
        uri: "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.josh_lambda.arn}/invocations"
        responses:
          default:
            statusCode: "200"
        passthroughBehavior: "when_no_match"
        httpMethod: "POST"
        contentHandling: "CONVERT_TO_TEXT"
        type: "aws_proxy"
definitions:
  Empty:
    type: "object"
    title: "Empty Schema"
---
EOF
}

resource "aws_api_gateway_account" "apigw_cloudwatch_account" {
  cloudwatch_role_arn = "${aws_iam_role.cloudwatch.arn}"
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = "${aws_iam_role.cloudwatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_method_settings" "s" {
  rest_api_id = "${aws_api_gateway_rest_api.communicate_josh_api.id}"
  stage_name  = "v1"
  method_path = "*/*"
  depends_on = ["aws_api_gateway_account.apigw_cloudwatch_account"]

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}
