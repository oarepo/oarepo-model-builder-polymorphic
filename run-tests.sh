#!/bin/bash

set -e

OAREPO_VERSION=${OAREPO_VERSION:-11}
OAREPO_VERSION_MAX=$((OAREPO_VERSION+1))

BUILDER_VENV=".venv-builder"
if test -d $BUILDER_VENV ; then
	rm -rf $BUILDER_VENV
fi

python3 -m venv $BUILDER_VENV
. $BUILDER_VENV/bin/activate
pip install -U setuptools pip wheel
pip install -e .

pip install oarepo-model-builder-vocabularies

if [ -d built-record ] ; then 
    rm -rf built-record
fi

.venv-builder/bin/oarepo-compile-model -vvv tests/model.yaml --output-directory built-record

VENV_TESTS=".venv-tests"

if test -d $VENV_TESTS ; then
	rm -rf $VENV_TESTS
fi

python3 -m venv $VENV_TESTS
. $VENV_TESTS/bin/activate

pip install -U setuptools pip wheel
pip install "oarepo>=$OAREPO_VERSION,<$OAREPO_VERSION_MAX"
pip install pytest-invenio
pip install -e './built-record'

pytest tests
