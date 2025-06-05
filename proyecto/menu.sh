#!/bin/bash

while true; do
    clear
    echo "======================================"
    echo "        🧀 MENÚ DE BACKUP 🛡️"
    echo "======================================"
    echo "1. Hacer backup (solo comprimir)"
    echo "2. Hacer backup (comprimir y encriptar)"
    echo "3. Restaurar backup"
    echo "4. Programar backup con Cron"
    echo "5. Salir"
    echo "======================================"
    read -p "Elegí una opción: " opcion

    case $opcion in
        1)
            read -p "📁 Origen del backup: " origen
            read -p "📂 Carpeta destino: " destino
            ./hacerBackup.sh -o "$origen" -d "$destino" -v
            read -p "Presioná enter para continuar..."
            ;;
        2)
            read -p "📁 Origen del backup: " origen
            read -p "📂 Carpeta destino: " destino
            read -p "🔐 Clave para encriptar: " clave
            ./hacerBackup.sh -o "$origen" -d "$destino" -e "$clave" -v
            read -p "Presioná enter para continuar..."
            ;;
        3)
            read -p "🗄️ Archivo a restaurar (.enc o .tar.gz): " archivo
            read -p "🔐 Clave (si es .enc, si no presionar Enter): " clave
            if [[ "$archivo" == *.enc ]]; then
                ./restaurar.sh -f "$archivo" -k "$clave" -a
            else
                ./restaurar.sh -f "$archivo" -k "no_necesaria" -x
            fi
            read -p "Presioná enter para continuar..."
            ;;
        4)
            echo "🕒 Programando backup con Cron..."
            crontab -e
            ;;
        5)
            echo "👋 Chau capo!"
            exit 0
            ;;
        *)
            echo "❌ Opción inválida"
            sleep 1
            ;;
    esac
done
