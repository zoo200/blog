## タスクロール
resource "aws_iam_role" "ecs-task" {
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
  name                 = "ecsTaskRole"
  path                 = "/"
}

# EcsExec
resource "aws_iam_policy" "ecs-exec" {
  name = "EcsExec"
  policy = templatefile("${path.module}/iam_policy/ecs_exec.json",
    {
  })
}

resource "aws_iam_role_policy_attachment" "ecs-exec" {
  policy_arn = aws_iam_policy.ecs-exec.arn
  role       = aws_iam_role.ecs-task.name
}

# fluent bit用
resource "aws_iam_policy" "fluent-bit" {
  name = "CoudwatchForFluentBit"
  policy = templatefile("${path.module}/iam_policy/fluent-bit.json",
    {
      bucket-arn = aws_s3_bucket.demo-fluent-bit.arn
  })
}

resource "aws_iam_role_policy_attachment" "fluent-bit" {
  policy_arn = aws_iam_policy.fluent-bit.arn
  role       = aws_iam_role.ecs-task.name
}



## タスク実行ロール
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
