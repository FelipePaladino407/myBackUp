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
# Validación de parámetros
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
    archivo_salida="${archivo%.enc}"
    echo "🔓 Desencriptando '$archivo' a '$archivo_salida'..."
    echo "[DEBUG] Ejecutando: ./decrypt_file \"$archivo\" \"$archivo_salida\" \"$clave\""
    ./decrypt_file "$archivo" "$archivo_salida" "$clave"
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
    carpeta_destino=$(dirname "$archivo")
    echo "📦 Descomprimiendo '$archivo' en '$carpeta_destino'..."
    tar -xzf "$archivo" -C "$carpeta_destino"
    if [ $? -eq 0 ]; then
        echo "✅ Descomprimido exitosamente"
    else
        echo "❌ Error al descomprimir"
        exit 1
    fi
}

# -------------------------------
# Flujo según opción
# -------------------------------
if [ "$solo_desencriptar" = true ]; then
    desencriptar
    espeak "Lets do it guys"

elif [ "$solo_descomprimir" = true ]; then
    descomprimir

elif [ "$restaurar_todo" = true ]; then
    desencriptar
    archivo="${archivo%.enc}"  # ahora es .tar.gz
    descomprimir

else
    usage
fi
