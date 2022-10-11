# Sets up the fargate-driven ECS cluster itself.

resource "aws_ecs_cluster" "Valheim" {
	name = "valheim"
	tags = {
		Cost = "Free"
	}
}

resource "aws_ecs_cluster_capacity_providers" "FargateSpot" {
	cluster_name       = aws_ecs_cluster.Valheim.name
	capacity_providers = [ var.enable_spot ? "FARGATE_SPOT" : "FARGATE" ]
}
