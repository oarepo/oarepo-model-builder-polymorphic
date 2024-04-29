import os

import pytest
from invenio_app.factory import create_app as _create_app
from invenio_vocabularies.records.models import VocabularyType


@pytest.fixture(scope="module")
def extra_entry_points():
    """Extra entry points to load the mock_module features."""
    return {}


@pytest.fixture(scope="module")
def app_config(app_config):
    app_config["JSONSCHEMAS_HOST"] = "localhost"
    app_config[
        "RECORDS_REFRESOLVER_CLS"
    ] = "invenio_records.resolver.InvenioRefResolver"
    app_config[
        "RECORDS_REFRESOLVER_STORE"
    ] = "invenio_jsonschemas.proxies.current_refresolver_store"
    app_config["RATELIMIT_AUTHENTICATED_USER"] = "200 per second"
    app_config["SEARCH_HOSTS"] = [
        {
            "host": os.environ.get("OPENSEARCH_HOST", "localhost"),
            "port": os.environ.get("OPENSEARCH_PORT", "9200"),
        }
    ]
    from oarepo_vocabularies.services.config import VocabulariesConfig
    from oarepo_vocabularies.resources.config import VocabulariesResourceConfig

    app_config["VOCABULARIES_SERVICE_CONFIG"] = VocabulariesConfig
    app_config["VOCABULARIES_RESOURCE_CONFIG"] = VocabulariesResourceConfig

    return app_config


@pytest.fixture(scope="module")
def create_app(instance_path, entry_points):
    """Application factory fixture."""
    return _create_app


@pytest.fixture(scope="module")
def vocabulary_service(app):
    """Vocabularies service object."""
    return app.extensions["invenio-vocabularies"].service

@pytest.fixture()
def vocab_cf(app, db, cache):
    from oarepo_runtime.services.custom_fields.mappings import prepare_cf_indices

    prepare_cf_indices()

@pytest.fixture()
def lang_type(app, db):
    """Get a language vocabulary type."""
    v = VocabularyType.create(id="languages", pid_type="lng")
    db.session.commit()
    return v


@pytest.fixture(scope="function")
def lang_data(vocabulary_service, lang_type, vocab_cf):
    from invenio_access.permissions import system_identity


    vocabulary_service.create(
        system_identity,
        {"id": "en", "type": "languages", "title": {"en": "English"}},
    )
