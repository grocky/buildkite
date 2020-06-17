.DEFAULT_GOAL := help

.PHONY: phony

tf-plan: phony ## terraform plan
	terraform plan -var-file test.tfvars
tf-apply: phony ## terraform apply
	terraform apply -var-file test.tfvars -auto-approve

test: ## Dummy test target
	echo "This is a test..."

build: ## Dummy build target
	echo "This is a build..."

graph.svg: graph.dot ## Generate terraform graph
	dot -Tsvg $^ > graph.svg
graph.dot: *.tf
	terraform graph > graph.dot

GREEN  := $(shell tput -Txterm setaf 2)
NC     := $(shell tput -Txterm sgr0)

help: phony ## Print this help message
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "${GREEN}%-20s${NC}%s\n", $$1, $$NF }' $(MAKEFILE_LIST)
