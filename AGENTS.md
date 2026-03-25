# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This repository contains university coursework (Université de Poitiers, Master 1 TDSI — Réseau et Sécurité): PDF lecture slides, a lab report (TP2 — chiffrement réseau), and a small Python validation utility.

There is no application server, database, or frontend. The only runnable component is a Python validation script.

### Python environment

- Python 3.12 is used. A virtual environment is created at `.venv/`.
- Dependencies: `pypdf`, `python-docx` (specified in `requirements.txt` on the `cursor/rapport-tp-chiffrement-reseau-e223` branch).
- System prerequisite: `python3.12-venv` must be installed (`sudo apt-get install -y python3.12-venv`).

### Running the validation / demo

If `requirements.txt`, `Makefile`, and `scripts/validate_environment.py` are present (they live on the `cursor/rapport-tp-chiffrement-reseau-e223` branch):

```bash
make setup   # creates .venv and installs deps
make demo    # runs scripts/validate_environment.py
```

On `main` (which has only PDFs), you can still validate the environment manually:

```bash
python3 -m venv .venv
.venv/bin/pip install pypdf python-docx
.venv/bin/python -c "from pypdf import PdfReader; print('OK')"
```

### Lint / Test / Build

There are no linters, test suites, or build steps configured in this repository. The validation script (`make demo`) is the closest equivalent to a test.
