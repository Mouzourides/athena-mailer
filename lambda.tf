resource "null_resource" "build_athena_mailer" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/build.sh"
    environment = {
      source_code_path = "./lambda/main"
      function_name = "athena-mailer"
      path_module = path.module
      path_cwd = path.cwd
    }
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
