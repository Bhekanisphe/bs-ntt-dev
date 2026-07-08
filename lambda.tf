# IAM role for Lambda execution
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}

# Permissions Lambda needs to read DynamoDB stream + write logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "connect:*",
          "dynamodb:*",
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Package the Lambda function code
data "archive_file" "lambda_file_error_handling" {
  type        = "zip"
  source_file = "${path.root}/lambda_functions/auto_test_lambda_error.py"
  output_path = "${path.root}/lambda_functions/function_error_handling.zip"
}

resource "aws_lambda_function" "bs-automated-testing_error_handling" {
  filename      = data.archive_file.lambda_file_error_handling.output_path
  function_name = "bs-automated-testing-error-handling"
  role          = aws_iam_role.lambda_role.arn
  handler       = "auto_test_lambda_error.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_file_error_handling.output_path)

  runtime = "python3.13"
  timeout = 300

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}



resource "aws_lambda_event_source_mapping" "lambda_dynamodb_trigger_error_handling" {
  event_source_arn  = aws_dynamodb_table.BS-Automated-Testing-Table.stream_arn
  function_name     = aws_lambda_function.bs-automated-testing_error_handling.arn
  starting_position = "LATEST"

  tags = {
    Name = "dynamodb-stream-mapping-error-handling"
    Environment = "development"
  }
}