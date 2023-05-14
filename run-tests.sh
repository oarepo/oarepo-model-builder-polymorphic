#!/bin/bash

set -e

.venv-builder/bin/pip install -e .

if [ -d built-record ] ; then 
    rm -rf built-record
fi

.venv-builder/bin/oarepo-compile-model -vvv tests/model.yaml --output-directory built-record

 if [ -d .venv ] ; then
     rm -rf .venv
 fi

 python3 -m venv .venv

 source .venv/bin/activate
 pip install -r tests/requirements.txt
 pip install -e ./built-record

 pytest tests
