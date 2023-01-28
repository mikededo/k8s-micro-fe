# .PHONY: all
# all: help
help: ## Display help screen
	@echo "Usage:"
	@echo "	make [COMMAND]"
	@echo "	make help \n"
	@echo "Commands: \n"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

define build
	@cd $(1) && docker build -t $(2) .
endef

define deploy
	@cd $(1) && kubectl apply -f ./deployment.yaml
endef

define delete_deploy
	@kubectl delete -n default deployment $(1)
endef

.PHONY: minikube-setup
minikube-setup: ## Sets the environment variables so that local images can be used
	eval $(minikube docker-env)

.PHONY: build-home
build-home: ## Generates the docker image for the home app
	$(call build, ./src/home, app-home)

.PHONY: deploy-home
deploy-home: ## Deploys the home deployment
	$(call deploy, ./src/home)

.PHONY: delete-home
delete-home: ## Deletes the home deployment
	$(call delete_deploy, apps-home)

