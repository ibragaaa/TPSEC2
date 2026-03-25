PYTHON ?= python3
VENV ?= .venv
PIP := $(VENV)/bin/pip
PY := $(VENV)/bin/python

.PHONY: setup demo clean

setup:
	$(PYTHON) -m venv $(VENV)
	$(PIP) install -r requirements.txt

demo:
	$(PY) scripts/validate_environment.py

clean:
	rm -rf $(VENV)
