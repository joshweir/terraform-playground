locals {
  account_num = "12345"
  my_list = [
    "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-COM-DATASTAGING-previews-dlq",
    "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-COM-DATASTAGING-commands-dlq"
  ]
}

data "null_data_source" "my_list_base_names_ds" {
  count = "${length(local.my_list)}"
  inputs = {
    value = "${replace(local.my_list[count.index], "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-COM-DATASTAGING-", "")}"
  }
}

output "my_list_base_names" {
  value = "${data.null_data_source.my_list_base_names_ds.*.outputs.value}"
}

output "my_list_base_names_json_stringified" {
  value = "${jsonencode(data.null_data_source.my_list_base_names_ds.*.outputs.value)}"
}
