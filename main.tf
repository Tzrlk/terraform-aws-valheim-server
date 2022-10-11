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

provider "aws" {
	default_tags {
		tags = {
			Application = "Valheim"
		}
	}
}
data "aws_region" "current" {}

provider "docker" {
	host = "tcp://localhost:2375"
}
