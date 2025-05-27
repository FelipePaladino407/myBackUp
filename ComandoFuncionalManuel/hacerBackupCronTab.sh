#!/bin/bash

directorioOrigen=""
directorioDestino=""
explicacionVerbose=false
comprimir=true
nombre=""

hora="*"
minuto="*"
diaMes="*"
mes="*"
diaSemana="*"

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
		-m)
		   minuto="$2"
		   shift 2
		   ;;
		-h)
		   hora="$2"
		   shift 2
		   ;;
		-dm)
		   diaMes="$2"
		   shift 2
		   ;;
		-nm)
		   mes="$2"
		   shift 2
		   ;;
		-ds)
		   diaSemana="$2"
		   shift 2
		   ;;
		-nc)
		   comprimir=false
		   shift
		   ;;	
	   	 -v)
		   explicacionVerbose=true
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

if [[ -z "$nombre" ]]; then 
	echo "S necesita un nombre fijo para mantener el back up"
	exit 1
fi

hacerBackup="/home/vboxuser/myBackUp/ComandoFuncionalManuel/hacerBackup.sh"

comando="$hacerBackup -o $directorioOrigen -d $directorioDestino -n $nombre"

tiempoCron="$minuto $hora $diaMes $mes $diaSemana"
echo "$tiempoCron"
if [[ "$comprimir" == false ]]; then 
	comando+=" -nc"
fi

if [[ "$explicacionVerbose" == true ]]; then 
	comando+=" -v"
fi

echo "origen $directorioOrigen"
echo "destino $directorioDestino"

linea="$tiempoCron $comando # BackupDe:$nombre"
(crontab -l 2>/dev/null | grep -v "BackupDe:$nombre" ; echo "$linea") | crontab -
echo "Ya termine"
echo "$linea"

