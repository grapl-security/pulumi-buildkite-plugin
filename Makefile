DOCKER_COMPOSE_CHECK := docker compose run --rm

.PHONY: all
all: format
all: lint
all: test

# Linting
########################################################################

.PHONY: lint
lint: lint-docker
lint: lint-pants
lint: lint-plugin
lint: lint-shell

.PHONY: lint-docker
lint-docker:  ## Lint Dockerfiles
	./pants --filter-target-type=docker_image lint ::

.PHONY: lint-pants
lint-pants: ## Ensure all files that should be covered by Pants actually are
	./pants tailor --check ::

.PHONY: lint-plugin
lint-plugin:
	$(DOCKER_COMPOSE_CHECK) plugin-linter

.PHONY: lint-shell
lint-shell:
	./pants lint ::

# Formatting
########################################################################

.PHONY: format
format: format-shell

.PHONY: format-shell
format-shell:
	./pants fmt ::

# Testing
########################################################################

.PHONY: test
test: test-plugin
test: test-shell

.PHONY: test-plugin
test-plugin:
	docker compose build && $(DOCKER_COMPOSE_CHECK) plugin-tester

.PHONY: test-shell
test-shell:
	./pants test ::
