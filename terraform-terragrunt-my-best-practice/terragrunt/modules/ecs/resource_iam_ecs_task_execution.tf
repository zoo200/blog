resource "aws_iam_role" "ecs-task-execution" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "ecsTaskExecutionRole"
  path                 = "/"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs-task-execution.name
}

# パラメーターストア用
resource "aws_iam_policy" "get-sercrets" {
  name        = "GetSecrets"
  policy = templatefile("${path.module}/policy/get-sercrets.json",
    {
      resource-parameterstore      = "arn:aws:ssm:${data.aws_region.now.name}:${data.aws_caller_identity.now.account_id}:parameter/*",
      resource-secretsmanager      = "arn:aws:secretsmanager:${data.aws_region.now.name}:${data.aws_caller_identity.now.account_id}:secret:*",
      resource-kms = data.aws_kms_key.ssm.arn
  })
}

resource "aws_iam_role_policy_attachment" "get-sercrets" {
  policy_arn = aws_iam_policy.get-sercrets.arn
  role       = aws_iam_role.ecs-task-execution.name
}
