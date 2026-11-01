# Lab 05 — Red de seguridad para datos personales (SOLUCIÓN).
#
# 1. Añade "import re" arriba de app/logging_config.py.
# 2. Pega el resto de este archivo en app/logging_config.py, antes de configure_logging.
# 3. Añade redact_pii al final de la lista shared de configure_logging.

SENSITIVE_KEYS = {"email", "card_number", "password", "authorization", "token"}
CARD_NUMBER = re.compile(r"\b[0-9]{13,19}\b")
EMAIL = re.compile(r"[\w.+-]+@[\w-]+(\.[\w-]+)+")


def redact_pii(_logger, _method, event_dict):
    """Red de seguridad: si un dato personal llega a un log, sale tapado."""
    for key, value in event_dict.items():
        if key in SENSITIVE_KEYS:
            event_dict[key] = "[REDACTED]"
        elif isinstance(value, str):
            event_dict[key] = EMAIL.sub("[EMAIL]", CARD_NUMBER.sub("[CARD]", value))
    return event_dict
