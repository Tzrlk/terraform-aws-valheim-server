#!/usr/bin/env make

.ONESHELL:
.DELETE_ON_ERROR:
.ALWAYS:
.PHONY: \
	init \
	validate \
	test \
	docs \
	site

#: Initialise the terraform workspace.
init: .terraform.lock.hcl
.terraform.lock.hcl: \
		main.tf
	${CMD_COMPOSE} run \
	terraform init \
		--backend=false

#: Validate the terraform code.
validate: tests/validation.done
tests/validation.done: \
		.terraform.lock.hcl
	terraform validate && \
	touch ${@}

#: Run tests against the code.
test: tests/junit.xml
tests/junit.xml: \
		$(wildcard *.tf) \
		$(wildcard tests/*/*.tf)
	terraform test \
		--junit-xml=/app/${@}

#: Generate terraform documentation
docs: terraform.adoc
terraform.adoc: \
		$(wildcard *.tf) \
		.terraform-docs.yml
	terraform-docs .
