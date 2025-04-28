#!/usr/bin/env bash
set -euo pipefail

# =====================================
# myBackUp - Script de backup configurable
# =====================================

# Archivo de configuración
CONFIG_FILE="config.ini"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# Valores por defecto en caso de no estar en config.ini
: "${SOURCE:=}"
: "${DEST:=}"
: "${EXCLUDE:=}"
: "${COMPRESS:=true}"
: "${INTERVAL:=86400}"
: "${ROTATION:=7}"
: "${LOGFILE:=logs/backup.log}"

# Función de ayuda
usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -s, --source DIR          Origen del backup
  -d, --dest DIR            Destino del backup
  -e, --exclude PATTERNS    Patrones de exclusión (ej: "*.tmp *.log")
  -c, --no-compress         Deshabilita compresión
  -i, --interval SEC        Intervalo entre backups (segundos)
  -r, --rotation N          Número de backups a mantener
  -l, --logfile FILE        Fichero de log
  -h, --help                Muestra esta ayuda
EOF
  exit 1
}

# Parseo de opciones CLI
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--source)    SOURCE="$2"; shift 2 ;;  
    -d|--dest)      DEST="$2"; shift 2 ;;  
    -e|--exclude)   EXCLUDE="$2"; shift 2 ;;  
    -c|--no-compress) COMPRESS=false; shift ;;  
    -i|--interval)  INTERVAL="$2"; shift 2 ;;  
    -r|--rotation)  ROTATION="$2"; shift 2 ;;  
    -l|--logfile)   LOGFILE="$2"; shift 2 ;;  
    -h|--help)      usage ;;  
    *) echo "Unknown option: $1"; usage ;;  
  esac
done

# Función principal de backup
do_backup() {
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_NAME="backup_${TIMESTAMP}.tar"

  if [[ "$COMPRESS" == "true" ]]; then
    BACKUP_NAME+=".gz"
    TAR_CMD=(tar -czf)
  else
    TAR_CMD=(tar -cf)
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup start: $SOURCE -> $DEST/$BACKUP_NAME" | tee -a "$LOGFILE"

  # Construir args de exclusión
  EXCLUDE_ARGS=()
  for pattern in $EXCLUDE; do
    EXCLUDE_ARGS+=(--exclude "$pattern")
  done

  # Ejecutar tar
  "${TAR_CMD[@]}" "$DEST/$BACKUP_NAME" "${EXCLUDE_ARGS[@]}" "$SOURCE" || {
    echo "Backup failed" | tee -a "$LOGFILE"
    return 1
  }

  # Rotación: eliminar backups antiguos
  ls -1td "$DEST"/backup_*.tar* | tail -n +$((ROTATION+1)) | xargs -r rm --

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup complete: $DEST/$BACKUP_NAME" | tee -a "$LOGFILE"
}

# Ejecución: único o en bucle si se definió LOOP=true
if [[ "${LOOP:-false}" == "true" ]]; then
  while true; do
    do_backup
    sleep "$INTERVAL"
  done
else
  do_backup
fi
