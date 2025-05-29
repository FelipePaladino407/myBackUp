archivo="$1"
nombre=""
directorioOrigen=""
directorioDestino=""
explicacionVerbose=false
comprimir=false
cron=false
nombre=$(sed -n '1p' "$archivo")
directorioOrigen=$(sed -n '2p' "$archivo")
directorioDestino=$(sed -n '3p' "$archivo")
lineaVerbose=$(sed -n '4p' "$archivo")

if [[ "$lineaVerbose" -eq 1 ]]; then
        explicacionVerbose=true
fi

lineaComprimir=$(sed -n '5p' "$archivo")

if [[ "$lineaComprimir" -eq 1 ]]; then
        comprimir=true
fi

lineaCrontab=$(sed -n '6p' "$archivo")

if [[ "$lineaCrontab" -eq 1 ]]; then
        cron=true
fi

echo "Datos:"
echo "Nombre: $nombre"
echo "DirOrigen: $directorioOrigen"
echo "DirDestino: $directorioDestino"
echo "Verbose: $explicacionVerbose"
echo "Comprimir: $comprimir"
echo "Crontab: $cron"


args="-o \"$directorioOrigen\" -d \"$directorioDestino\" -n \"$nombre\""

if [[ "$verbose" == true ]]; then
	args="$args -v"
fi

if [[ "$comprimir" == true ]]; then
        args="$args -nc"
fi



if [[ "$cron" == false ]]; then
	eval  ./hacerBackup.sh $args
else
	argsCron="$args -m '*' -h '*' -dm '*' -nm '*' -ds '*'"

	eval ./hacerBackupCronTab.sh $argsCron
fi


