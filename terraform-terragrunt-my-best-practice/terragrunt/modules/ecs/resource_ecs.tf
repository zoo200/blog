resource "aws_ecs_cluster" "demo" {
  name               = "demo"
}

resource "aws_ecs_cluster_capacity_providers" "demo" {
  cluster_name = aws_ecs_cluster.demo.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
}

# Simply specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "demo" {
  task_definition = aws_ecs_task_definition.demo.family
  depends_on = [aws_ecs_task_definition.demo]
}

resource "aws_ecs_task_definition" "demo" {
  family                   = "demo"

  cpu                      = var.ecs-config["cpu"]
  memory                   = var.ecs-config["memory"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs-task.arn
  execution_role_arn       = aws_iam_role.ecs-task-execution.arn

  container_definitions = jsonencode([
    {
      name      = "demo"
      image     = "nginx"
      cpu       = var.ecs-config["cpu"]
      memory    = var.ecs-config["memory"]
      essential = true
      portMappings = [
            {
              containerPort = 80
              hostPort = 80
            }
      ]
      secrets = [
        {
          name = "DB_USER"
          valueFrom  = var.ssm-parameter-secrets-demo-db-user-name
        },
        {
          name = "DB_PASS"
          valueFrom  = var.ssm-parameter-secrets-demo-db-pass-name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "demo" {
  name = "demo"

  cluster = aws_ecs_cluster.demo.name

  deployment_controller {
    type = "ECS"
  }

  desired_count                      = 1
  launch_type                        = "FARGATE"
  enable_execute_command             = true
  
  load_balancer {
    container_name   = "demo"
    container_port   = 80
    target_group_arn = aws_lb_target_group.demo.arn
  }

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [var.sg-container-http-id]
    subnets = var.subnet-demo-ids

  }

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.demo.family}:${max(aws_ecs_task_definition.demo.revision, data.aws_ecs_task_definition.demo.revision)}"
}