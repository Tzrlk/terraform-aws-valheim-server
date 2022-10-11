# Sets up the service-specific parts of the setup

locals {
	ValheimPorts = {
		Min    = 2456
		Max    = 2458
		Status = 80
		Super  = 9001
		Ddns   = 9002
	}
	TaskResFactors = {
		Cpu = 2
		Mem = 6
	}
	ContainerDefaults = {
		essential       = false
		mountPoints     = []
		volumesFrom     = []
		linuxParameters = {
			initProcessEnabled = true
		}
		environment = [
			{ name = "TZ", value = var.server_timezone },
		]
		healthCheck = {
			interval    = 30
			retries     = 3
			timeout     = 5
			startPeriod = 300
		}
		logConfiguration = {
			logDriver = "awslogs",
			options   = {
				awslogs-group  = aws_cloudwatch_log_group.ValheimLogs.name
				awslogs-region = data.aws_region.current.name
			}
		}
	}
	ContainerConfigs = {
		Valheim    = local.ContainerValheim
		DnsUpdater = local.ContainerDns
	}
}

resource "aws_ecs_task_definition" "Valheim" {
	requires_compatibilities = [ "FARGATE" ]
	network_mode             = "awsvpc"

	execution_role_arn = aws_iam_role.ValheimTask.arn
	task_role_arn      = aws_iam_role.ValheimExec.arn

	cpu    = sum(values(local.ContainerConfigs)[*]["cpu"])
	memory = sum(values(local.ContainerConfigs)[*]["memory"])

	family                = "valheim"
	container_definitions = jsonencode([
		local.ContainerConfigs.Valheim,
		local.ContainerConfigs.DnsUpdater,
	])

	tags = {
		Cost = "Free"
	}
}

resource "aws_ecs_service" "Valheim" {
	lifecycle { ignore_changes = [ desired_count ] }
	depends_on = [
		aws_secretsmanager_secret_version.ServerPass,
		aws_secretsmanager_secret_version.DnsUpdater,
	]

	name            = "valheim"
	cluster         = aws_ecs_cluster.Valheim.id
	task_definition = aws_ecs_task_definition.Valheim.id
	launch_type     = "FARGATE"

	enable_execute_command = true
	force_new_deployment   = true

	desired_count                      = var.enable_server ? 1 : 0
	deployment_minimum_healthy_percent = 0
	deployment_maximum_percent         = 100

	network_configuration {
		subnets          = [ aws_subnet.Subnet.id ]
		security_groups  = [ aws_security_group.Cluster.id ]
		assign_public_ip = true
	}

	tags = {
		Cost = "Moderate"
	}
}
