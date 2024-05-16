# Set this to ~use it everywhere in the project setup
PYTHON_VERSION ?= 3.12.3
# the directories containing the library modules this repo builds
LIBRARY_DIRS = mylibrary
# build artifacts organized in this Makefile
BUILD_DIR ?= build

# PyTest options
PYTEST_HTML_OPTIONS = --html=$(BUILD_DIR)/report.html --self-contained-html
PYTEST_TAP_OPTIONS = --tap-combined --tap-outdir $(BUILD_DIR)
PYTEST_COVERAGE_OPTIONS = --cov=$(LIBRARY_DIRS)
PYTEST_OPTIONS ?= $(PYTEST_HTML_OPTIONS) $(PYTEST_TAP_OPTIONS) $(PYTEST_COVERAGE_OPTIONS)

# MyPy typechecking options
MYPY_OPTS ?= --python-version $(basename $(PYTHON_VERSION)) --show-column-numbers --pretty --html-report $(BUILD_DIR)/mypy
# Python installation artifacts
PYTHON_VERSION_FILE=.python-version

# Manually set the Python installation directory
PYTHON_VERSION_DIR = C:/Users/mathe/AppData/Local/Programs/Python/Python312

PIP ?= pip3

POETRY_OPTS ?=
POETRY ?= poetry $(POETRY_OPTS)
RUN_PYPKG_BIN = $(POETRY) run

COLOR_ORANGE = \033[33m
COLOR_RESET = \033[0m

##@ Utility


.PHONY: version-python
version-python: ## Echos the version of Python in use
	@echo $(PYTHON_VERSION)

##@ Testing

.PHONY: test
test: ## Runs tests
	$(RUN_PYPKG_BIN) pytest \
		$(PYTEST_OPTIONS) \
		tests/*.py

##@ Building and Publishing

.PHONY: build
build: ## Runs a build
	$(POETRY) build

.PHONY: publish
publish: ## Publish a build to the configured repo
	$(POETRY) publish $(POETRY_PUBLISH_OPTIONS_SET_BY_CI_ENV)

.PHONY: deps-py-update
deps-py-update: pyproject.toml ## Update Poetry deps, e.g. after adding a new one manually
	$(POETRY) update

##@ Setup
# Manually set the Python installation directory
$(PYTHON_VERSION_FILE): 
	@echo $(PYTHON_VERSION) > $(PYTHON_VERSION_FILE)

.PHONY: deps
deps: deps-brew deps-py  ## Installs all dependencies

.PHONY: deps-brew
deps-brew: Brewfile ## Installs development dependencies from Homebrew
	brew bundle --file=Brewfile
	@echo "$(COLOR_ORANGE)Ensure that pyenv is setup in your shell.$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)It should have something like 'eval \$$(pyenv init -)'$(COLOR_RESET)"

.PHONY: deps-py
deps-py: $(PYTHON_VERSION_FILE) ## Installs Python development and runtime dependencies
	$(PIP) install --upgrade \
		--index-url $(PYPI_PROXY) \
		pip
	$(PIP) install --upgrade \
                                     		--index-url $(PYPI_PROXY) \
                                     		poetry
	$(POETRY) install

##@ Code Quality

.PHONY: check
check: check-py ## Runs linters and other important tools

.PHONY: check-py
check-py: check-py-flake8 check-py-black check-py-mypy ## Checks only Python files

.PHONY: check-py-flake8
check-py-flake8: ## Runs flake8 linter
	$(RUN_PYPKG_BIN) flake8 .

.PHONY: check-py-black
check-py-black: ## Runs black in check mode (no changes)
	$(RUN_PYPKG_BIN) black --check --line-length 118 --fast .

.PHONY: check-py-mypy
check-py-mypy: ## Runs mypy
	$(RUN_PYPKG_BIN) mypy $(MYPY_OPTS) $(LIBRARY_DIRS)

.PHONY: format-py
format-py: ## Runs black, makes changes where necessary
	$(RUN_PYPKG_BIN) black .

.PHONY: format-autopep8
format-autopep8:
	$(RUN_PYPKG_BIN) autopep8 --in-place --recursive .

.PHONY: format-isort
format-isort:
	$(RUN_PYPKG_BIN) isort --recursive .

.PHONY: migrate
migrate:
	docker-compose exec web python manage.py migrate --noinput

.PHONY: seed
seed:
	poetry run python manage.py seed
