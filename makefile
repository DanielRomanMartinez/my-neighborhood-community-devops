SHELL = /bin/bash

API_CONTAINER:=neighborhood.api
LOCAL_API_DOMAIN:=local-api.my-neighborhood-community.com

.PHONY: help
help: ## Display this help message
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# Docker commands
.PHONY: start stop rebuild

start: ## Start docker
	docker-compose up -d

stop: ## Stop docker
	docker-compose stop

rebuild: ## Rebuild docker
	docker rm -f neighborhood.nginx neighborhood.api neighborhood.database neighborhood.adminer neighborhood.rabbitmq > /dev/null
	docker-compose build

#
.PHONY: sh
sh: ## gets inside a container, use 's' variable to select a service. make sh s=php
		docker-compose exec $(s) bash -l

# API commands
.PHONY: api-prepare api-install api-composer api-update database-create database-migrate database-rebuild api-fixtures api-test api-test-coverage api-queues api-queues-purge

api-prepare: ## Download api code
	git clone git@github.com:DanielRomanMartinez/my-neighborhood-community-api.git ../api

api-install: ## Install api dependencies and create database
	make api-composer
	make database-create
	make database-migrate

api-composer: ## Update api dependencies
	cd ../api/ && git pull && cd -
	docker exec ${API_CONTAINER} bash -c "composer install"

api-update: ## Update api code and database
	make api-composer database-migrate

api-setup: ## Update api code, install dependencies and rebuild database
	make api-composer
	make database-rebuild

database-create: ## Create database
	docker exec ${API_CONTAINER} bash -c "php bin/console doctrine:database:drop --force --if-exists"
	docker exec ${API_CONTAINER} bash -c "php bin/console doctrine:database:create"

database-migrate: ## Run database migrations
	docker exec ${API_CONTAINER} bash -c "php bin/console doctrine:migrations:migrate -n"

database-rebuild: ## Rebuild DB
	make database-create
	make database-migrate

api-fixtures: ## Load api database fixtures
	docker exec ${API_CONTAINER} bash -c "php bin/console doctrine:fixtures:load --append -n"

api-test: ## Run api tests with coverage
	docker exec ${API_CONTAINER} bash -c "./bin/phpunit"

api-test-coverage: ## Run api tests with coverage
	docker exec ${API_CONTAINER} bash -c "./bin/phpunit --coverage-html coverage"

api-fixer-lint: ## Run php-cs-fixer and do lint
	docker exec ${API_CONTAINER} bash -c "./vendor/bin/php-cs-fixer fix --config=.php_cs.dist  --diff --dry-run"

api-fixer-fix: ## Run php-cs-fixer and do fix
	docker exec ${API_CONTAINER} bash -c "./vendor/bin/php-cs-fixer fix --config=.php_cs.dist"

api-queues: ## Setup queues and executes consumers. Use 'm' to set number of consumers. make api-queues m=4
	docker exec ${API_CONTAINER} bash -c "php bin/console messenger:setup-transports"
	docker exec ${API_CONTAINER} bash -c "php bin/console messenger:consume async --limit=$(if $(m),$(m),1)"

api-queues-purge: ## Purge queues messages
	docker exec neighborhood.rabbitmq bash -c "rabbitmqadmin -u rabbitmq -p rabbitmq list queues | cut -d '|' -f 2 | sed -e 's/ //g' | xargs -n1 -I@ rabbitmqadmin -u rabbitmq -p rabbitmq purge queue name=@"

.PHONY: sites
sites: ## Adding custom domain to hosts. If you have a MacOS, please add the following parameter: make sites e=mac
	$(info  ************ Adding sites to hosts file...)
	@echo " " | sudo tee -a /etc/hosts > /dev/null
	@echo "# NEIGHBORHOOD CONTRACTS" | sudo tee -a /etc/hosts > /dev/null
	@env=$(e);if [ "$$env" == "mac" ]; then \
		echo "127.0.0.1 ${LOCAL_API_DOMAIN}" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' ${API_CONTAINER}) ${LOCAL_API_DOMAIN}" | sudo tee -a /etc/hosts > /dev/null; \
	fi \

# ElasticSearch command
.PHONY: es-index
es-index: ## Create action_logs index in ElasticSearch
	cd elk/elasticsearch && sh create_index.sh && cd -