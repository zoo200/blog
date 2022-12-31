resource "aws_ecs_cluster" "demo" {
  name = "demo"
}

resource "aws_ecs_cluster_capacity_providers" "demo" {
  cluster_name = aws_ecs_cluster.demo.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
}

# Simply specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "demo" {
  task_definition = aws_ecs_task_definition.demo.family
  depends_on      = [aws_ecs_task_definition.demo]
}

resource "aws_ecs_task_definition" "demo" {
  family = "demo"

  cpu                = var.ecs-config["cpu"]
  memory             = var.ecs-config["memory"]
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs-task.arn
  execution_role_arn = aws_iam_role.ecs-task-execution.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx"
      cpu       = var.ecs-config["cpu"] / 2
      memory    = var.ecs-config["memory"] / 2
      essential = true


      logConfiguration = {
        ### 普通にawslogsでcloudwatchへ出力
        # logDriver = "awslogs"
        # options = {
        #   "awslogs-group"         = aws_cloudwatch_log_group.demo-nginx.name
        #   "awslogs-region"        = data.aws_region.now.name
        #   "awslogs-stream-prefix" = "ecs"
        # }

        # ## FireLens経由でcloudwatchへ出力
        # logDriver = "awsfirelens"
        # options = {
        #   "Name" : "cloudwatch_logs",
        #   "region" : data.aws_region.now.name,
        #   "log_group_name" : aws_cloudwatch_log_group.demo-nginx-from-fluent-bit.name,
        #   "auto_create_group" : "true",
        #   "log_stream_prefix" : "ecs/",
        # }

        # ## FireLens経由で3へ出力
        # logDriver = "awsfirelens"
        # options = {
        #   "Name" : "s3",
        #   "region" : data.aws_region.now.name,
        #   "bucket" : aws_s3_bucket.demo-fluent-bit.id,
        #   "total_file_size" : "1M",
        #   "use_put_object" : "On",
        # }

        ## FireLens経由で詳細はFluentBit設定ファイルで
        logDriver = "awsfirelens"

      },
      portMappings = [
        {
          containerPort = var.port["http"]
          hostPort      = var.port["http"]
        }
      ]
    },
    {
      name = "fluent-bit"
      # ## AWS公式のFluentBitイメージ
      # image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      ## 自作FluentBitイメージ
      image = aws_ecr_repository.fluent-bit.repository_url

      cpu       = var.ecs-config["cpu"] / 2
      memory    = var.ecs-config["memory"] / 2
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.demo-fluent-bit.name
          "awslogs-region"        = data.aws_region.now.name
          "awslogs-stream-prefix" = "ecs"
        }
      },
      firelensConfiguration = {
        type = "fluentbit"
        "options" : {
          "config-file-type" : "file",
          "config-file-value" : "/fluent-bit/etc/fluent-bit-custom.conf"
        }
      }
      # なぜか差分でるの回避
      "mountPoints" : [],
      "volumesFrom" : [],
      "portMappings" : [],
      "environment" : [],
      "user" : "0",
    }
  ])
}

resource "aws_ecs_service" "demo" {
  name = "demo"

  cluster = aws_ecs_cluster.demo.name

  deployment_controller {
    type = "ECS"
  }

  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    container_name   = "nginx"
    container_port   = var.port["http"]
    target_group_arn = aws_lb_target_group.demo.arn
  }

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.container-http.id]
    subnets          = aws_subnet.demo.*.id

  }

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.demo.family}:${max(aws_ecs_task_definition.demo.revision, data.aws_ecs_task_definition.demo.revision)}"
}
