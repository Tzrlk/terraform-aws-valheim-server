terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = ">= 4"
		}
		docker = {
			source = "kreuzwerker/docker"
		}
		external = {
			source = "hashicorp/external"
		}
		http = {
			source = "hashicorp/http"
		}
		local = {
			source = "hashicorp/local"
		}
	}
}

data "aws_region" "current" {}
