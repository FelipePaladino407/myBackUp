#!/bin/bash
# menu.sh - Menu backup:

# Ruta a los scripts, de backup y eso:
HACER_BACKUP="$HOME/Documents/SO/myBackUp/proyecto/hacerBackup.sh"
HACER_CRON="$HOME/Documents/SO/myBackUp/proyecto/hacerBackupCronTab"
RESTAURAR="$HOME/Documents/SO/myBackUp/proyecto/restaurar.sh"

function pausar() {
  read -rp $'\nPresiona ENTER para continuar...' _
}

function opcion_hacer_backup() {
  echo "=== Hacer Backup Manual ==="
  read -rp "Directorio Origen: " origen
  read -rp "Directorio Destino: " destino
  read -rp "Nombre (deja vacío para usar fecha/hora): " nombre

  # ¿Comprimir?
  read -rp "¿Comprimir? (s/n) [s]: " c
  comprimir_arg=""
  [[ "$c" =~ ^[Nn] ]] && comprimir_arg="-nc"

  # ¿Encriptar?
  read -rp "¿Encriptar? (s/n) [n]: " e
  encriptar_arg=""
  if [[ "$e" =~ ^[Ss] ]]; then
    read -rsp "Clave de encriptación: " clave; echo
    encriptar_arg="-e $clave"
  fi

  # Verbose opcional
  read -rp "¿Modo verbose? (s/n) [n]: " v
  [[ "$v" =~ ^[Ss] ]] && verbose_arg="-v"

  # Procedemos a realizar la infame ejecucion:
  bash "$HACER_BACKUP" -o "$origen" -d "$destino" -n "$nombre" $comprimir_arg $encriptar_arg $verbose_arg
  pausar
}

function opcion_backup_cron() {
  echo "=== Programar Backup con cron ==="
  read -rp "Directorio Origen: " origen
  read -rp "Directorio Destino: " destino
  read -rp "Nombre fijo para backup: " nombre

  echo "Configura la programación cron (usa * para 'cualquiera'):"
  read -rp "Minuto (0–59) [*]: " m; m=${m:-*}
  read -rp "Hora (0–23) [*]: " h; h=${h:-*}
  read -rp "Día del mes (1–31) [*]: " dm; dm=${dm:-*}
  read -rp "Mes (1–12) [*]: " mm; mm=${mm:-*}
  read -rp "Día de la semana (0–7, 0 y 7 domingo) [*]: " ds; ds=${ds:-*}

  # ¿Comprimir?
  read -rp "¿Comprimir? (s/n) [s]: " c
  comprimir_arg=""
  [[ "$c" =~ ^[Nn] ]] && comprimir_arg="-nc"

  # Verbose opcional
  read -rp "¿Modo verbose? (s/n) [n]: " v
  [[ "$v" =~ ^[Ss] ]] && verbose_arg="-v"

  # Infame ejecucion:
  bash "$HACER_CRON" -o "$origen" -d "$destino" -n "$nombre" -m "$m" -h "$h" -dm "$dm" -nm "$mm" -ds "$ds" $comprimir_arg $verbose_arg
  pausar
}

function opcion_restaurar() {
  echo "=== Restaurar Backup ==="
  read -rp "Archivo a restaurar (.enc o .tar.gz): " archivo
  read -rsp "Clave (solo si está encriptado): " clave; echo

  echo "Modo de restauración:"
  echo "  1) Solo desencriptar"
  echo "  2) Solo descomprimir"
  echo "  3) Desencriptar y descomprimir"
  read -rp "Elige 1, 2 o 3: " m
  case "$m" in
    1) mod="-d" ;;
    2) mod="-x" ;;
    3) mod="-a" ;;
    *) echo "Opción inválida"; pausar; return ;;
  esac

  bash "$RESTAURAR" -f "$archivo" -k "$clave" $mod
  pausar
}

function opcion_listar_backups() {
  echo "=== Listar Backups en un directorio ==="
  read -rp "Directorio a inspeccionar: " dir
  ls -lh "$dir" | grep -E '\.tar(\.gz)?(\.enc)?$' || echo "No se encontraron backups"
  pausar
}

function opcion_limpiar_antiguos() {
  echo "=== Eliminar Backups Antiguos ==="
  read -rp "Directorio de backups: " dir
  read -rp "¿Borrar archivos más viejos que cuántos días? " dias
  find "$dir" -maxdepth 1 -type f -mtime +"$dias" -name 'backup-*' -exec rm -i {} \;
  pausar
}

# ====== Bucle principal ======
while true; do
  clear
  cat <<EOF
====================================
     AUTOMATIZADOR DE BACKUPS
====================================
1) Hacer backup
2) Hacer backup con cron
3) Restaurar backup
4) Listar backups disponibles
5) Eliminar backups antiguos
6) Salir
EOF

  read -rp "Selecciona una opción [1-6]: " opt
  case "$opt" in
    1) opcion_hacer_backup ;;
    2) opcion_backup_cron ;;
    3) opcion_restaurar ;;
    4) opcion_listar_backups ;;
    5) opcion_limpiar_antiguos ;;
    6) echo "¡Listo?, Joya, por favor deje su rating en google maps!"; exit 0 ;;
    *) echo "Opción inválida."; pausar ;;
  esac
done
