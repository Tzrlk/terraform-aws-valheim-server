# Input variables. I prefer to put them next to the relevant code, but whatever.

## World Settings #############################################################
variable "world_name" {
	description = "The name of the valheim world to load. Defaults to server name."
	type        = string
}

## Server Options #############################################################
variable "server_name" {
	description = "The name of the world and server."
	type        = string
	default     = ""
}
variable "server_pass" {
	description = "The password for the Valheim server."
	type        = string
	sensitive   = true
}
variable "server_image" {
	description = "The docker image to use for running valheim."
	type        = string
	default     = "tzrlk/valheim-server-aws:latest"
}
variable "server_admins" {
	description = "Steam ids of admins."
	type        = set(string)
	default     = []
}
variable "server_timezone" {
	description = "The timezone this server operates in."
	type        = string
	default     = "UTC"
}

## FreeDNS Configuration ######################################################
variable "freedns_image" {
	description = "The docker image to use for updating the freedns service."
	type        = string
	default     = "qmcgaw/ddns-updater:latest"
}
variable "freedns_host" {
	description = "The hostname to register the server address with"
	type        = string
}
variable "freedns_domain" {
	description = "Which of the freedns domains to register the host under."
	type        = string
	default     = "jumpingcrab.com"
}
variable "freedns_token" {
	description = "The token used to authenticate against freedns."
	type        = string
	sensitive   = true
}

## Toggles ####################################################################
variable "enable_server" {
	description = "Whether or not to run the server."
	type        = bool
	default     = false
}
variable "enable_flowlogs" {
	description = "Monitor all network traffic in the VPC."
	type        = bool
	default     = false
}
variable "enable_spot" {
	description = "Whether or not to schedule on Fargate Spot and take the risk of a shutdown."
	type        = bool
	default     = true
}
