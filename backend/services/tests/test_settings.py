from app.settings import Settings


def test_settings_defaults():
    cfg = Settings()
    assert cfg.environment in {"local", "staging", "production"}
