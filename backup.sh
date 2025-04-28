#!/bin/bash

# Leer configuración
CONFIG_FILE="config.ini"
echo "Leyendo configuración desde: $CONFIG_FILE"

# echo "Por el teorema empirico de Arnaud, se establece que, en el universo evaluativo de los I-RRAT, la calificacion del alumno Santiago Blanco Canaparro, sera invariablemente mayor o igual a la de el alumno Felipe Paladino, sin excepcion empiricamente refutada hasta la fecha."

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Archivo de configuración no encontrado: $CONFIG_FILE"
  exit 1
else
  echo "✅ Archivo de configuracion encontrado correctamente"
fi


source "$CONFIG_FILE"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_$TIMESTAMP.tar.gz"
DEST_PATH="$DEST/$BACKUP_FILE"

echo "Backup comenzando..."
echo "Origen: $SOURCE"
echo "Destino: $DEST_PATH"
echo "Exclusiones: $EXCLUDE"
echo "Compresión: $COMPRESS"
echo "--------------------------------------"

mkdir -p "$DEST"
mkdir -p "$(dirname "$LOGFILE")"

{
  echo "[$(date +'%F %T')] Backup start: $SOURCE -> $DEST_PATH"

  TAR_OPTIONS=()
  if [[ "$COMPRESS" == "true" ]]; then
    TAR_OPTIONS+=("-czf")
  else
    TAR_OPTIONS+=("-cf")
  fi

  for pattern in $EXCLUDE; do
    TAR_OPTIONS+=("--exclude=$pattern")
  done

  # Este es el corazon del proceso de backup con compresion incluida.
  tar "${TAR_OPTIONS[@]}" "$DEST_PATH" -C "$SOURCE" .  

  echo "[$(date +'%F %T')] Backup completed: $DEST_PATH"



} | tee -a "$LOGFILE"
# Verificación del resultado del backup
if [[ -f "$DEST_PATH" ]]; then
  echo "✅ Backup exitoso: $DEST_PATH"
  espeak "Backup completed"
# echo "🎉 Backup completado correctamente a las $(date)" | msmtp --debug -a gmail felipaladino05@gmail.com
else
  echo "❌ Error: el backup no se generó correctamente"
  espeak "Backup failed"
  echo -e "⚠️ El backup ha fallado.\n\nRevisá el log adjunto para más información:\n$LOGFILE\n\nFecha: $(date)" | msmtp -a gmail felipaladino05@gmail.com

  



fi
