resource "aws_iam_role" "lambda_role" {
  name = "wms_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "Name" = "wms"
    "Env"  = "Dev"
  }

}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn

}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/hello-python.zip"
  function_name = "wms_Lambda_Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}