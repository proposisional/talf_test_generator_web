#!/bin/bash
set -e

cd /var/www/html

# Asegurar directorios requeridos por Yii/Apache
mkdir -p runtime web/assets

if [ "${DEBUG_STARTUP:-0}" = "1" ]; then
  echo "[DEBUG_STARTUP] Variables de entorno relevantes:"
  echo "[DEBUG_STARTUP] DB_HOST=${DB_HOST:-<empty>}"
  echo "[DEBUG_STARTUP] DB_PORT=${DB_PORT:-<empty>}"
  echo "[DEBUG_STARTUP] DB_NAME=${DB_NAME:-<empty>}"
  echo "[DEBUG_STARTUP] DB_USER=${DB_USER:-${DB_USERNAME:-<empty>}}"
  if [ -n "${DB_PASS:-${DB_PASSWORD:-}}" ]; then
    echo "[DEBUG_STARTUP] DB_PASS=<set>"
  else
    echo "[DEBUG_STARTUP] DB_PASS=<empty>"
  fi

  if command -v getent >/dev/null 2>&1; then
    echo "[DEBUG_STARTUP] DNS getent hosts ${DB_HOST:-db}:"
    getent hosts "${DB_HOST:-db}" || true
  fi
fi

if [ ! -d vendor ]; then
  echo "Instalando dependencias Composer..."
  composer install --no-interaction --prefer-dist --no-progress --optimize-autoloader
fi

# Depuración (evitar volcar secretos en logs)
if [ "${DEBUG_STARTUP:-0}" = "1" ]; then
  echo "--------------------------------------------------"
  echo "[DEBUG] Migrations en /var/www/html/migrations:"
  ls -la /var/www/html/migrations 2>/dev/null || echo "[DEBUG] (no existe carpeta migrations)"
  echo "[DEBUG] Estado de migraciones (php yii migrate/new):"
  php yii migrate/new --interactive=0 || true
  echo "[DEBUG] Historial de migraciones (últimas 20):"
  php yii migrate/history --limit=20 --interactive=0 || true
  echo "[DEBUG] DATABASE_URL (sanitizada):"
  if [ -n "${DATABASE_URL:-}" ]; then
    echo "${DATABASE_URL}" | sed -E 's#(://[^:/]+):[^@]+@#\1:***@#'
  else
    echo "<NO ESTABLECIDA>"
  fi
  echo "--------------------------------------------------"
fi

# Ejecutar migraciones automáticamente (controlable vía RUN_MIGRATIONS).
if [ "${RUN_MIGRATIONS:-1}" = "1" ]; then
  echo "Intentando ejecutar migraciones..."

  # Espera/reintento simple por si la DB tarda en estar disponible.
  attempts="${DB_WAIT_ATTEMPTS:-20}"
  sleep_seconds="${DB_WAIT_SECONDS:-3}"

  i=1
  while [ "$i" -le "$attempts" ]; do
    mode="${MIGRATE_MODE:-up}"
    if [ "$mode" = "fresh" ]; then
      cmd=(php yii migrate/fresh --interactive=0)
    else
      cmd=(php yii migrate/up --interactive=0)
    fi

    if "${cmd[@]}"; then
      echo "Migraciones aplicadas con éxito o ya estaban al día."
      break
    fi
    echo "Migración falló (intento $i/$attempts). Reintentando en ${sleep_seconds}s..."
    i=$((i+1))
    sleep "$sleep_seconds"
  done

  if [ "$i" -gt "$attempts" ]; then
    echo "ADVERTENCIA: No se pudo ejecutar migraciones tras ${attempts} intentos. La aplicación continuará, pero la BD podría no estar lista."
    # Decidí no usar 'exit 1' para permitir que el servidor inicie incluso si las migraciones fallan.
  fi
else
  echo "RUN_MIGRATIONS=${RUN_MIGRATIONS:-0}: saltando migraciones."
fi

# Ajustar permisos mínimos
chown -R www-data:www-data runtime web/assets

# Asegurar escritura, lectura y ejecución en carpeta octave (y subcarpetas relevantes)
if [ -d octave ]; then
  chown -R www-data:www-data octave
  find octave -type d -exec chmod 755 {} \;
  find octave -type f -exec chmod 644 {} \;
fi

# Iniciar Apache en foreground
echo "Iniciando Apache..."
apache2-foreground
