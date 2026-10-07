#!/bin/bash
set -e

echo "Esperando a Postgres..."
for i in {1..30}; do
  python3 <<'PY'
import os, sys
import psycopg2
try:
    psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "notesdb"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
    )
    sys.exit(0)
except Exception:
    sys.exit(1)
PY
  if [ $? -eq 0 ]; then
    break
  fi
  echo "Postgres no disponible, reintentando en 2s..."
  sleep 2
done

echo "Postgres listo. Inicializando DB..."
python3 - <<'PY'
from app import init_db
init_db()
print("DB inicializada")
PY

exec "$@"
