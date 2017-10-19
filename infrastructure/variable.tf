variable "function_name" {
  default = "apex-golang-sample_hello"
}

variable "aws_account_id" {
  default = "975765818137"
}

variable "lambda_iam_role" {
  default = "arn:aws:iam::975765818137:role/apex-golang-sample_lambda_function"
}

variable "lambda_uri" {
  default = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-1:975765818137:function:apex-golang-sample_hello/invocations"
}