resource "aws_iam_role" "lambda_exec_role" {
  name = "athena_mailer_role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": "sts:AssumeRole",
"Principal": {
"Service": "lambda.amazonaws.com"
}
}
]
}
  EOF
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid = "AllowInvokingLambdas"
    effect = "Allow"

    resources = [
      "arn:aws:lambda:*:*:function:*"
    ]

    actions = [
      "lambda:InvokeFunction"
    ]
  }

  statement {
    sid = "AllowCreatingLogGroups"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*"
    ]

    actions = [
      "logs:CreateLogGroup"
    ]
  }

  statement {
    sid = "AllowWritingLogs"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid = "AllowAthenaQueryExecution"
    effect = "Allow"

    resources = [
      "arn:aws:athena:eu-west-1:*",
      "arn:aws:glue:eu-west-1:*:*"
    ]

    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "glue:GetTable"
    ]
  }
  statement {
    sid = "AllowS3Access"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::nikmouz-athena-query-results/*",
      "arn:aws:s3:::nikmouz-athena-query-results",
      "arn:aws:s3:::nikmouz.dev-logs/*",
      "arn:aws:s3:::nikmouz.dev-logs"
    ]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "athena_mailer_iam_policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
  role = aws_iam_role.lambda_exec_role.name
}
