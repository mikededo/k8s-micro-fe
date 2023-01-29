# .PHONY: all
# all: help
help: ## Display help screen
	@echo "Usage:"
	@echo "	make [COMMAND]"
	@echo "	make help \n"
	@echo "Commands: \n"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## FUNCTIONS

define _build
	@cd $(1) && docker build -t $(2) .
endef

define _deploy
	cd $(1) && kubectl apply -f ./deployment.yaml
endef

define _delete
	@kubectl delete -n monorepo-nmspc deployment $(1)
endef

## COMANDS

.PHONY: minikube-setup
minikube-setup: ## Sets the environment variables so that local images can be used
	eval $(minikube docker-env)

.PHONY: change-ctx
change-ctx: ## Changes the kubectl context so that it matches the wanted namespace
	kubectl config set-context --current --namespace monorepo-nmspc

.PHONY: build
build: ## Generates the docker image for the target app
	$(call _build, ./src/$(target), app-$(target))

.PHONY: deploy
deploy: ## Deploys the target deployment
	$(call _deploy, ./src/$(target))

.PHONY: delete
delete: ## Deletes the target deployment
	$(call _delete, apps-$(target))

## GROUP COMMANDS

.PHONE: build-all
build-all: ## Builds all the deployments (home, settings, user)
	@for i in home settings user; do make build target="$$i"; done

.PHONE: deploy-all
deploy-all: ## Deploys all the deployments (home, settings, user)
	@for i in home settings user; do make deploy target="$$i"; done

.PHONE: delete-all
delete-all: ## Deletes all the deployments (home, settings, user)
	@for i in home settings user; do make delete target="$$i"; done
