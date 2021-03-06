.DEFAULT_GOAL := all
isort = isort -rc arq tests
black = black -S -l 120 --target-version py37 arq tests

.PHONY: install
install:
	pip install -U pip setuptools
	pip install -r requirements.txt
	pip install -e .[watch]

.PHONY: format
format:
	$(isort)
	$(black)

.PHONY: lint
lint:
	python setup.py check -rms
	flake8 arq/ tests/
	$(isort) --check-only
	$(black) --check arq

.PHONY: test
test:
	pytest --cov=arq

.PHONY: testcov
testcov:
	pytest --cov=arq && (echo "building coverage html"; coverage html)

.PHONY: all
all: testcov lint

.PHONY: clean
clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf .cache
	rm -rf htmlcov
	rm -rf *.egg-info
	rm -f .coverage
	rm -f .coverage.*
	rm -rf build
	make -C docs clean
	python setup.py clean

.PHONY: docs
docs:
	make -C docs html
	rm -rf docs/_build/html/old
	unzip -q docs/old-docs.zip
	mv old-docs docs/_build/html/old
	@echo "open file://`pwd`/docs/_build/html/index.html"

.PHONY: deploy-docs
deploy-docs: docs
	cd docs/_build/ && cp -r html site && zip -r site.zip site
	@curl -H "Content-Type: application/zip" -H "Authorization: Bearer ${NETLIFY}" \
			--data-binary "@docs/_build/site.zip" https://api.netlify.com/api/v1/sites/arq-docs.netlify.com/deploys
