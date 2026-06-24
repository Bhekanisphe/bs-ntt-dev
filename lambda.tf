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

# Permissions Lambda needs to read DynamoDB stream + write logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Resource = aws_dynamodb_table.BS-Automated-Testing-Table.stream_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
            Effect: "Allow",
            Action: [
                "connect:*",
                "ds:CreateAlias",
                "ds:AuthorizeApplication",
                "ds:CreateIdentityPoolDirectory",
                "ds:DeleteDirectory",
                "ds:DescribeDirectories",
                "ds:UnauthorizeApplication",
                "firehose:DescribeDeliveryStream",
                "firehose:ListDeliveryStreams",
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kms:DescribeKey",
                "kms:ListAliases",
                "lex:GetBots",
                "lex:ListBots",
                "lex:ListBotAliases",
                "logs:CreateLogGroup",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets",
                "lambda:ListFunctions",
                "ds:CheckAlias",
                "profile:ListAccountIntegrations",
                "profile:GetDomain",
                "profile:ListDomains",
                "profile:GetProfileObjectType",
                "profile:ListProfileObjectTypeTemplates"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "profile:AddProfileKey",
                "profile:CreateDomain",
                "profile:CreateProfile",
                "profile:DeleteDomain",
                "profile:DeleteIntegration",
                "profile:DeleteProfile",
                "profile:DeleteProfileKey",
                "profile:DeleteProfileObject",
                "profile:DeleteProfileObjectType",
                "profile:GetIntegration",
                "profile:GetMatches",
                "profile:GetProfileObjectType",
                "profile:ListIntegrations",
                "profile:ListProfileObjects",
                "profile:ListProfileObjectTypes",
                "profile:ListTagsForResource",
                "profile:MergeProfiles",
                "profile:PutIntegration",
                "profile:PutProfileObject",
                "profile:PutProfileObjectType",
                "profile:SearchProfiles",
                "profile:TagResource",
                "profile:UntagResource",
                "profile:UpdateDomain",
                "profile:UpdateProfile"
            ],
            Resource: "arn:aws:profile:*:*:domains/amazon-connect-*"
        },
        {
            Effect: "Allow",
            Action: [
                "s3:CreateBucket",
                "s3:GetBucketAcl"
            ],
            Resource: "arn:aws:s3:::amazon-connect-*"
        },
        {
            Effect: "Allow",
            Action: [
                "servicequotas:GetServiceQuota"
            ],
            Resource: "arn:aws:servicequotas:*:*:connect/*"
        },
        {
            Effect: "Allow",
            Action: "iam:CreateServiceLinkedRole",
            Resource: "*",
            Condition: {
                "StringEquals": {
                    "iam:AWSServiceName": "connect.amazonaws.com"
                }
            }
        },
        {
            Effect: "Allow",
            Action: "iam:DeleteServiceLinkedRole",
            Resource: "arn:aws:iam::*:role/aws-service-role/connect.amazonaws.com/AWSServiceRoleForAmazonConnect*"
        },
        {
            Effect: "Allow",
            Action: "iam:CreateServiceLinkedRole",
            Resource: "arn:aws:iam::*:role/aws-service-role/profile.amazonaws.com/*",
            Condition: {
                "StringEquals": {
                    "iam:AWSServiceName": "profile.amazonaws.com"
                }
            }
        },
        {
            Action: [
                "dynamodb:*",
                "dax:*",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:GetMetricData",
                "datapipeline:ActivatePipeline",
                "datapipeline:CreatePipeline",
                "datapipeline:DeletePipeline",
                "datapipeline:DescribeObjects",
                "datapipeline:DescribePipelines",
                "datapipeline:GetPipelineDefinition",
                "datapipeline:ListPipelines",
                "datapipeline:PutPipelineDefinition",
                "datapipeline:QueryObjects",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "iam:GetRole",
                "iam:ListRoles",
                "kms:DescribeKey",
                "kms:ListAliases",
                "sns:CreateTopic",
                "sns:DeleteTopic",
                "sns:ListSubscriptions",
                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "sns:Subscribe",
                "sns:Unsubscribe",
                "sns:SetTopicAttributes",
                "lambda:CreateFunction",
                "lambda:ListFunctions",
                "lambda:ListEventSourceMappings",
                "lambda:CreateEventSourceMapping",
                "lambda:DeleteEventSourceMapping",
                "lambda:GetFunctionConfiguration",
                "lambda:DeleteFunction",
                "resource-groups:ListGroups",
                "resource-groups:ListGroupResources",
                "resource-groups:GetGroup",
                "resource-groups:GetGroupQuery",
                "resource-groups:DeleteGroup",
                "resource-groups:CreateGroup",
                "tag:GetResources",
                "kinesis:ListStreams",
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary"
            ],
            Effect: "Allow",
            Resource: "*"
        },
        {
            Action: "cloudwatch:GetInsightRuleReport",
            Effect: "Allow",
            Resource: "arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"
        },
        {
            Action: [
                "iam:PassRole"
            ],
            Effect: "Allow",
            Resource: "*",
            Condition: {
                "StringLike": {
                    "iam:PassedToService": [
                        "application-autoscaling.amazonaws.com",
                        "application-autoscaling.amazonaws.com.cn",
                        "dax.amazonaws.com"
                    ]
                }
            }
        },
        {
            Effect: "Allow",
            Action: [
                "iam:CreateServiceLinkedRole"
            ],
            Resource: "*",
            Condition: {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.dynamodb.amazonaws.com",
                        "dax.amazonaws.com",
                        "dynamodb.application-autoscaling.amazonaws.com",
                        "contributorinsights.dynamodb.amazonaws.com",
                        "kinesisreplication.dynamodb.amazonaws.com"
                    ]
                }
            }
        }
    ]
  })
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

  runtime = "python3.13"

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}

resource "aws_lambda_event_source_mapping" "lambda_dynamodb_trigger" {
  event_source_arn  = aws_dynamodb_table.BS-Automated-Testing-Table.stream_arn
  function_name     = aws_lambda_function.bs-automated-testing.arn
  starting_position = "LATEST"

  tags = {
    Name = "dynamodb-stream-mapping"
  }
}