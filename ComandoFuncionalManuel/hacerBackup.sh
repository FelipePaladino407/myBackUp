#!/bin/bash
nombre=""
fecha=$(date +%y-%m-%d)
hora=$(date +%H:%M)
directorioOrigen=""
directorioDestino=""
explicacionVerbose=false
comprimir=true


while [[ $# -gt 0 ]]; do 
	opcion="$1"
	case "$opcion" in 
		-o) 
		   directorioOrigen="$2"
		   shift 2
		   ;;
		-d)
		   directorioDestino="$2"
		   shift 2
		   ;;
		-n)
		   nombre="$2"
		   shift 2
		   ;;
		-v)
		   explicacionVerbose=true 
		   shift 
		   ;;
	        -nc)
		   comprimir=false
		   shift
		   ;;
		 *)	
		   echo "Opcion no valida"
	       	   exit 1
		   ;;

	esac
done

echo "termine el while"
if [[ -z "$directorioOrigen" || -z "$directorioDestino" ]]; then 
	echo "Los datos ingresados no son validos"
	exit 1
fi

if [[ "$comprimir" == true ]]; then 
	terminacion="tar.gz"
	tipoTar="czf"
else 
	terminacion="tar"
	tipoTar="cf"
fi

if [[ -n "$nombre" ]]; then
	archivoGuardado="$directorioDestino/${nombre}.${terminacion}"
else
	archivoGuardado="$directorioDestino/backup-${fecha}_${hora}.${terminacion}"
fi

mkdir -p "$directorioDestino"

if [[ "$explicacionVerbose" == true ]]; then 
	echo "Guardando backup de  $directorioOrigen a $directorioDestino"
fi
tar $tipoTar "$archivoGuardado" -C "$(dirname "$directorioOrigen")" "$(basename "$directorioOrigen")"

echo "llegue"
if [[ "$explicacionVerbose" == true ]]; then
	echo "El back se ha realizado con exito"
fi
