.PHONY: all
all: format
all: lint
all: test

# Linting
########################################################################

.PHONY: lint
lint: lint-docker
lint: lint-plugin
lint: lint-shell

.PHONY: lint-docker
lint-docker:  ## Lint Dockerfiles
	./pants filter --target-type=docker_image :: | xargs ./pants lint

.PHONY: lint-plugin
lint-plugin:
	docker-compose run --rm plugin-linter

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
	docker-compose build && docker-compose run --rm plugin-tester

.PHONY: test-shell
test-shell:
	./pants test ::
