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
}

# Package the Lambda function code
data "archive_file" "lambda_file" {
  type        = "zip"
  source_file = "${path.root}/lambda_functions/auto_test_lambda.py"
  output_path = "${path.root}/lambda_functions/function.zip"
}

# Lambda function
resource "aws_lambda_function" "bs-automated-testing" {
  filename      = data.archive_file.lambda_file.output_path
  function_name = "bs-automated-testing-iac"
  role          = aws_iam_role.lambda_role.arn
  handler       = "auto_test_lambda.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_file.output_path)
  //code_sha256   = data.archive_file.lambda_file.output_base64sha256

  runtime = "python3.13"

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}