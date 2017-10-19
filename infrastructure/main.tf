resource "aws_api_gateway_rest_api" "RecommendationServiceAPI" {
  name = "${var.function_name}"
}

resource "aws_api_gateway_resource" "RecommendationServiceResource" {
  rest_api_id = "${aws_api_gateway_rest_api.RecommendationServiceAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.RecommendationServiceAPI.root_resource_id}"
  path_part   = "sample"
}

resource "aws_api_gateway_method" "RecommendationServiceMethod" {
  rest_api_id      = "${aws_api_gateway_rest_api.RecommendationServiceAPI.id}"
  resource_id      = "${aws_api_gateway_resource.RecommendationServiceResource.id}"
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "RecommendationServiceIntegration" {
  rest_api_id             = "${aws_api_gateway_rest_api.RecommendationServiceAPI.id}"
  resource_id             = "${aws_api_gateway_resource.RecommendationServiceResource.id}"
  http_method             = "${aws_api_gateway_method.RecommendationServiceMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_uri}"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:ap-northeast-1:${var.aws_account_id}:function:${var.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:ap-northeast-1:${var.aws_account_id}:${aws_api_gateway_rest_api.RecommendationServiceAPI.id}/*/${aws_api_gateway_method.RecommendationServiceMethod.http_method}${aws_api_gateway_resource.RecommendationServiceResource.path}"

  depends_on = ["aws_api_gateway_resource.RecommendationServiceResource"]
}

resource "aws_api_gateway_deployment" "RecommendationServiceDeployment" {
  depends_on = ["aws_api_gateway_method.RecommendationServiceMethod"]

  rest_api_id = "${aws_api_gateway_rest_api.RecommendationServiceAPI.id}"
  stage_name  = "development"
}

resource "aws_api_gateway_api_key" "RecommendationServiceApiKey" {
  name = "RecommendationServiceTrial"
}

resource "aws_api_gateway_usage_plan" "RecommendationServiceUsagePlan" {
  name = "RecommendationServiceUsagePlan"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.RecommendationServiceAPI.id}"
    stage  = "${aws_api_gateway_deployment.RecommendationServiceDeployment.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = "${aws_api_gateway_api_key.RecommendationServiceApiKey.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.RecommendationServiceUsagePlan.id}"
}