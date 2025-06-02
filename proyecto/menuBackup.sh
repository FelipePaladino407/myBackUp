#!/bin/bash

hacerBackup="./hacerBackup.sh"
programarBackup="./CronTab.sh"

# Función para leer rutas con validación
leer_ruta() {
    local mensaje="$1"
    local ruta
    while true; do
        read -p "$mensaje: " ruta
        if [[ -d "$ruta" ]]; then
            echo "$ruta"
            return
        else
            echo "La ruta no existe. Intente nuevamente."
        fi
    done
}

restaurar_backup() {
    echo "--- Restaurar Backup ---"
    archivo=$(leer_ruta "Ingrese la ruta del archivo de backup (.tar, .tar.gz o .enc)")

    if [[ "$archivo" == *.enc ]]; then
        read -s -p "Ingrese la clave de encriptación: " clave
        echo ""
        archivo_descifrado="/tmp/backup-restaurado.tar.gz"
        ./decrypt_file "$archivo" "$archivo_descifrado" "$clave"
        
        if [[ $? -ne 0 ]]; then
            echo "Error: Falló la desencriptación"
            return
        fi

        archivo="$archivo_descifrado"
    fi

    read -p "Ingrese el directorio donde quiere restaurar el backup: " destino

    if [[ ! -d "$destino" ]]; then
        echo "El directorio no existe. Creándolo..."
        mkdir -p "$destino" || { echo "No se pudo crear el directorio. Abortando."; return; }
    fi

    echo "Restaurando backup en $destino..."
    tar -xzf "$archivo" -C "$destino"

    if [[ $? -eq 0 ]]; then
        echo "Backup restaurado exitosamente. Archivos restaurados:"
        find "$destino" -type f -newermt "-1 minute" | sed "s|^|  - |"
    else
        echo "Ocurrió un error al restaurar el backup."
    fi
}

# Menú principal
while true; do
    echo ""
    echo "========== MENÚ DE BACKUPS =========="
    echo "1) Hacer backup ahora"
    echo "2) Programar backup automático (cron)"
    echo "3) Ver tareas cron actuales"
    echo "4) Eliminar tarea cron por nombre"
    echo "5) Restaurar backup"
    echo "6) Salir"
    echo "======================================"
    read -p "Seleccione una opción [1-6]: " opcion

    case "$opcion" in
        1)
            echo "--- Realizar Backup Inmediato ---"
            origen=$(leer_ruta "Ingrese el directorio ORIGEN")
            destino=$(leer_ruta "Ingrese el directorio DESTINO")
            read -p "Ingrese un nombre para el archivo de backup (opcional): " nombre
            read -p "¿Desea explicación verbose? (s/n): " verbose
            read -p "¿Desea comprimir el backup? (s/n): " comprimir
            read -p "¿Desea encriptar el backup? (s/n): " encriptar

            cmd="$hacerBackup -o \"$origen\" -d \"$destino\""

            if [[ -n "$nombre" ]]; then
                cmd+=" -n \"$nombre\""
            fi
            [[ "$verbose" == "s" ]] && cmd+=" -v"
            [[ "$comprimir" == "n" ]] && cmd+=" -nc"

            if [[ "$encriptar" == "s" ]]; then
                read -s -p "Ingrese la clave de encriptación: " clave
                echo ""
                cmd+=" -e \"$clave\""
            fi

            eval "$cmd"
            ;;

        2)
            echo "--- Programar Backup con CRON ---"
            origen=$(leer_ruta "Ingrese el directorio ORIGEN")
            destino=$(leer_ruta "Ingrese el directorio DESTINO")
            read -p "Ingrese un nombre FIJO para el archivo de backup: " nombre
            read -p "Minuto (0-59): " minuto
            read -p "Hora (0-23): " hora
            read -p "Día del mes (1-31 o *): " diaMes
            read -p "Mes (1-12 o *): " mes
            read -p "Día de la semana (0-6, donde 0 es domingo, o *): " diaSemana
            read -p "¿Verbose? (s/n): " verbose
            read -p "¿Comprimir backup? (s/n): " comprimir

            cmd="$programarBackup -o \"$origen\" -d \"$destino\" -n \"$nombre\" -m \"$minuto\" -h \"$hora\" -dm \"$diaMes\" -nm \"$mes\" -ds \"$diaSemana\""
            [[ "$verbose" == "s" ]] && cmd+=" -v"
            [[ "$comprimir" == "n" ]] && cmd+=" -nc"

            eval "$cmd"
            ;;

        3)
            echo "--- Tareas cron actuales ---"
            crontab -l | grep "# BackupDe:" || echo "No hay backups programados."
            ;;

        4)
            echo "--- Eliminar tarea cron por nombre ---"
            read -p "Ingrese el nombre del backup a eliminar: " nombreEliminar
            crontab -l | grep -v "# BackupDe:$nombreEliminar" | crontab -
            echo "Tarea eliminada (si existía)."
            ;;

	5)
	    restaurar_backup
	    ;;

        6)
            echo "Saliendo del sistema de backups."
            break
            ;;

        *)
            echo "Opción inválida. Intente nuevamente."
            ;;
    esac
done
