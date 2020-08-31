resource "null_resource" "build_athena_mailer" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/build.sh"
  }
}

data "archive_file" "create_package" {
  depends_on = [null_resource.build_athena_mailer]
  source_dir = "${path.cwd}/build/"
  output_path = var.output_path
  type = "zip"
}

resource "aws_lambda_function" "athena_mailer_lambda" {
  depends_on = [data.archive_file.create_package]
  function_name = "athena-mailer"
  description = "Lambda to obtain and mail nikmouz.dev Athena query results"
  handler = "main.handler"
  role = aws_iam_role.lambda_exec_role.arn
  runtime = "python3.8"
  memory_size = 128
  timeout = 300
  source_code_hash = data.archive_file.create_package.output_base64sha256
  filename = data.archive_file.create_package.output_path
}

resource "aws_cloudwatch_event_rule" "every_first_of_month_at_12" {
  name                = "every-first-of-month-at-12"
  schedule_expression = "cron(0 12 1 * ? *)"
  description         = "Fires at 1200 every 1st day of the month"
}

resource "aws_cloudwatch_event_target" "execute_athena_mailer_lambda" {
  rule      = aws_cloudwatch_event_rule.every_first_of_month_at_12.name
  target_id = "execute_athena_mailer_lambda"
  arn       = aws_lambda_function.athena_mailer_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_execute_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.athena_mailer_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_first_of_month_at_12.arn
}
