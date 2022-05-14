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
  name        = "EcsExec"
  policy = templatefile("${path.module}/policy/ecs-exec.json",
    {
  })
}

resource "aws_iam_role_policy_attachment" "ecs-exec" {
  policy_arn = aws_iam_policy.ecs-exec.arn
  role       = aws_iam_role.ecs-task.name
}
