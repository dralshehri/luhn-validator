# Makefile config
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Python environment variables
VENV=.venv
PYTHON=$(VENV)/bin/python


.PHONY: install ## Install development requirments
install: clean
	rm -fr .venv
	python3 -m venv .venv --copies
	$(PYTHON) -m pip install -U pip setuptools
	$(PYTHON) -m pip install -U pytest pytest-cov black wheel twine
	$(PYTHON) -m pip install -e .

.PHONY: test ## Run unit tests
test: clean-test
	$(PYTHON) -m pytest

.PHONY: test-cov ## Run tests with code coverage
test-cov: clean-test
	$(PYTHON) -m pytest --cov --cov-report term --cov-report html
	$(PYTHON) -m webbrowser $(PWD)/htmlcov/index.html

.PHONY: format ## Format code with Black
format:
	$(PYTHON) -m black -l 79 -t py35 src tests setup.py

.PHONY: build ## Build and check the package
build: clean
	$(PYTHON) setup.py sdist bdist_wheel
	$(PYTHON) -m twine check dist/*

.PHONY: deploy ## Deploy the package to PyPI
deploy: build
	$(PYTHON) -m twine upload dist/*

.PHONY: clean ## Remove all artifacts
clean: clean-test clean-pyc clean-build

.PHONY: clean-test ## Remove tests artifacts
clean-test:
	rm -fr .pytest_cache
	rm -f .coverage
	rm -fr htmlcov

.PHONY: clean-pyc ## Remove python artifacts
clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-build ## Remove build artifacts
clean-build:
	rm -fr build
	rm -fr dist
	rm -fr .eggs
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

.PHONY: help
help:
	@echo "Please use \`make <target>\` where <target> is one of:"
	@grep -E '^\.PHONY: [a-zA-Z_-]+ .*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = "(: |##)"}; {printf "\033[36m%-15s\033[0m %s\n", $$2, $$3}'

