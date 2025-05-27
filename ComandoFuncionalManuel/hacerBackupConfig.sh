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
	echo "Entre en el if 1"
fi

lineaComprimir=$(sed -n '5p' "$archivo")

if [[ "$lineaComprimir" -eq 1 ]]; then
        comprimir=true
        echo "Entre en el if 2"
fi

lineaCrontab=$(sed -n '6p' "$archivo")

if [[ "$lineaCrontab" -eq 1 ]]; then
        cron=true
	echo "entre en el if 3"
fi

echo "$nombre"
echo "$directorioOrigen"
echo "$directorioDestino"
echo "$explicacionVerbose"
echo "$comprimir"
echo "$cron"


args="-o \"$directorioOrigen\" -d \"$directorioDestino\" -n \"$nombre\""

if [[ "$verbose" == true ]]; then
	args="$args -v"
fi

if [[ "$comprimir" == true ]]; then
        args="$args -nc"
fi



if [[ "$cron" == false ]]; then
	echo "No hago crontab$
	eval ./hacerBackup.sh $args
else
	echo "Hago con crontab"
	argsCron="$args -m '*' -h '*' -dm '*' -nm '*' -ds '*'"
	if [[ "$explicacionVerbose" == true ]]; then
        argsCron="$argsCron -v"
	fi

	if [[ "$comprimir" == true ]]; then
        argsCron="$argsCron -nc"
	fi

eval ./hacerBackupCronTab.sh $argsCron
fi


