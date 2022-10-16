# Security group and NACL config.

resource "aws_security_group" "Cluster" {
	vpc_id = aws_vpc.Vpc.id
	name   = "cluster"
	tags   = {
		Cost = "Free"
	}
}

data "http" "ExternalIp" {
	url = "https://ifconfig.me"
}
locals {
	ExternalIp = trimspace(data.http.ExternalIp.response_body)
}

module "NetworkSecurity" {
	source  = "tzrlk/network-security/aws"
	version = "0.1.0"

	SecurityGroupIds = {
		Cluster = aws_security_group.Cluster.id
	}
	CidrBlocks = {
		Anywhere = "0.0.0.0/0"
		AdminBox = "${data.http.ExternalIp.response_body}/32"
	}
	PortRanges = {
		Ddns    = { Min = 9002, Max = 9002 }
		DnsTcp  = { Min =   53, Max =   53 }
		DnsUdp  = { Min =   53, Max =   53, Proto = "udp" }
		Http    = { Min =   80, Max =   80 }
		Https   = { Min =  443, Max =  443 }
		Super   = { Min = 9001, Max = 9001 }
		Valheim = { Min = 2456, Max = 2458, Proto = "udp" }
	}
	Rules = {
		AdminBox = { Cluster = [
			"Super",
		] }
		Anywhere = { Cluster = [
			"Ddns",
			"DnsTcp",
			"DnsUdp",
			"Http",
			"Valheim",
		] }
		Cluster = { Anywhere = [
			"Http",
			"Https",
			"DnsTcp",
			"DnsUdp",
			"Valheim",
		] }
	}
}

resource "aws_network_acl" "Firewall" {
	vpc_id     = aws_vpc.Vpc.id
	subnet_ids = [ aws_subnet.Subnet.id ]
	ingress { # Valheim UDP
		rule_no    = 10
		protocol   = "udp"
		from_port  = local.ValheimPorts.Min
		to_port    = local.ValheimPorts.Max
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	ingress { # Valheim TCP
		rule_no    = 15
		protocol   = "tcp"
		from_port  = local.ValheimPorts.Min
		to_port    = local.ValheimPorts.Max
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	ingress { # valheim status
		rule_no    = 20
		protocol   = "tcp"
		from_port  = local.ValheimPorts.Status
		to_port    = local.ValheimPorts.Status
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	ingress { # Ephemeral responses
		rule_no    = 30
		protocol   = "tcp"
		from_port  = 1024
		to_port    = 65535
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	ingress { # DNS TCP
		rule_no    = 40
		protocol   = "tcp"
		from_port  = 53
		to_port    = 53
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	ingress { # DNS UDP
		rule_no    = 45
		protocol   = "udp"
		from_port  = 53
		to_port    = 53
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	egress { # HTTP
		rule_no    = 10
		protocol   = "tcp"
		from_port  = 80
		to_port    = 80
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	egress { # HTTPS
		rule_no    = 20
		protocol   = "tcp"
		from_port  = 443
		to_port    = 443
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	egress { # DNS
		rule_no    = 30
		protocol   = "tcp"
		from_port  = 53
		to_port    = 53
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	egress { # DNS UDP
		rule_no    = 35
		protocol   = "udp"
		from_port  = 53
		to_port    = 53
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	egress { # Ephemeral responses
		rule_no    = 40
		protocol   = "tcp"
		from_port  = 1024
		to_port    = 65535
		cidr_block = "0.0.0.0/0"
		action     = "allow"
	}
	tags = {
		Cost = "Free"
	}
}
