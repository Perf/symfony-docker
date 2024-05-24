args = $(filter-out $@,$(MAKECMDGOALS))
export HOST_USER = $(shell id -un)
export SYMFONY_VERSION=7.1.*
export STABILITY=dev

# Executables (local)
DOCKER_COMP = $(if $(test -f docker-compose),docker-compose,docker compose)
BROWSER     = open

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up down logs sh chown browse template docker-restart

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the Docker containers in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

down: ## Stop the Docker containers
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Shows live logs from all containers, or from specified one, for example: 'make logs php'
	@$(DOCKER_COMP) logs --tail=$(if $(args),all,20) --follow $(args)

sh: ## Logs in into PHP container as current user, or to any specified container as root, for example: 'make sh mysql'
	@$(DOCKER_COMP) exec $(if $(args),$(args),php) $(if $(args),sh,su ${HOST_USER})

chown: ## Reclaim ownership of files created by the Docker container
	@$(DOCKER_COMP) run --rm php chown -R ${HOST_USER}:${HOST_USER} .

browse: ## Open http-exposed services in the browser
	@$(BROWSER) "https://localhost:443/api"
	@$(BROWSER) "http://localhost:8025/"

## —— Upstream Template ————————————————————————————————————————————————————————
template: ## Update this repo with changes from upstream template
	curl -sSL https://raw.githubusercontent.com/coopTilleuls/template-sync/main/template-sync.sh | sh -s -- https://github.com/dunglas/symfony-docker

## —— System ———————————————————————————————————————————————————————————————————
docker-restart: ## Restart Docker service
	sudo service docker restart
