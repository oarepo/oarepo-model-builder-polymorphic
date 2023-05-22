#!/bin/bash

set -e

if [ -d .venv-builder ] ; then
  rm -rf .venv-builder
fi

python3 -m venv .venv-builder
.venv-builder/bin/pip install -U setuptools pip wheel

.venv-builder/bin/pip install -e .

if [ -d built-record ] ; then 
    rm -rf built-record
fi

.venv-builder/bin/oarepo-compile-model -vvv tests/model.yaml --output-directory built-record

 if [ -d .venv-tests ] ; then
     rm -rf .venv-tests
 fi

 python3 -m venv .venv-tests
.venv-tests/bin/pip install -U setuptools pip wheel

 source .venv-tests/bin/activate
 pip install -r tests/requirements.txt
 pip install -e ./built-record

 pytest tests
