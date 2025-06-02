#!/bin/bash

# -------------------------------------------------------
# HOLA HOLA! Esto es un script para restaurar el archivo.
# -------------------------------------------------------

function usage() {
    echo "Uso: $0 -f <archivo> -k <clave> [-d|-x|-a]"
    echo "  -f <archivo> : archivo a restaurar (.enc o .tar.gz)"
    echo "  -k <clave>   : clave para desencriptar"
    echo "  -d           : solo desencriptar"
    echo "  -x           : solo descomprimir"
    echo "  -a           : desencriptar y descomprimir (restaurar todo)"
    exit 1
}

# -------------------------------
# Validasion de parametros
# -------------------------------

while getopts "f:k:dxa" opt; do
    case "$opt" in
        f) archivo="$OPTARG" ;;
        k) clave="$OPTARG" ;;
        d) solo_desencriptar=true ;;
        x) solo_descomprimir=true ;;
        a) restaurar_todo=true ;;
        *) usage ;;
    esac
done

if [ -z "$archivo" ] || [ -z "$clave" ]; then
    usage
fi

# -------------------------------
# Desencriptar
# -------------------------------
function desencriptar() {
    nombre_salida="${archivo%.enc}"
    echo "🔓 Desencriptando '$archivo' a '$nombre_salida'..."
    echo "[DEBUG] Ejecutando: ./decrypt_file \"$archivo\" \"$nombre_salida\" \"$clave\""
    ./decrypt_file "$archivo" "$nombre_salida" "$clave"
    if [ $? -eq 0 ]; then
        echo "✅ Desencriptado exitosamente"
    else
        echo "❌ Error al desencriptar"
        exit 1
    fi
}

# -------------------------------
# Descomprimir
# -------------------------------
function descomprimir() {
    echo "📦 Descomprimiendo '$archivo'..."
    tar -xzf "$archivo"
    if [ $? -eq 0 ]; then
        echo "✅ Descomprimido exitosamente"
    else
        echo "❌ Error al descomprimir"
        exit 1
    fi
}

# -------------------------------
# Flujo segun opcion.
# -------------------------------
if [ "$solo_desencriptar" = true ]; then
    desencriptar
    espeak "Lets do it guys"

elif [ "$solo_descomprimir" = true ]; then
    descomprimir

elif [ "$restaurar_todo" = true ]; then
    desencriptar
    archivo="${archivo%.enc}"  # actualiza el nombre desencriptado
    descomprimir

else
    usage
fi
