locals {
  account_num = "12345"
  the_env = "COM-DATASTAGING"
  my_list = [
    "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-${local.the_env}-previews-dlq",
    "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-${local.the_env}-commands-dlq"
  ]
}

data "null_data_source" "my_list_base_names_ds" {
  count = "${length(local.my_list)}"
  inputs = {
    value = "${replace(local.my_list[count.index], "arn:aws:sqs:ap-southeast-2:${local.account_num}:communicate-${local.the_env}-", "")}"
    value2 = "${local.the_env}"
  }
}

output "my_list_base_names" {
  value = "${data.null_data_source.my_list_base_names_ds.*.outputs.value}"
}

output "my_list_base_names_json_stringified" {
  value = "${jsonencode(data.null_data_source.my_list_base_names_ds.*.outputs.value)}"
}

output "my_list_in_json_object" {
  value = "{ \"dlqBaseNames\": ${jsonencode(data.null_data_source.my_list_base_names_ds.*.outputs.value)}, \"env\": \"${upper(local.the_env)}\" }"
}