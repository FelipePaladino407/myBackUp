nombre=""
directorioOrigen=""
directorioDestino=""
explicacionVerbose=false
comprimir=false
cron=false
nombre=$(sed -n '1p' hacerBackup.config.txt)
directorioOrigen=$(sed -n '2p' hacerBackup.config.txt)
directorioDestino=$(sed -n '3p' hacerBackup.config.txt)
lineaVerbose=$(sed -n '4p' hacerBackup.config.txt)

if [[ "$lineaVerbose" -eq 1 ]]; then
        explicacionVerbose=true
	echo "Entre en el if 1"
fi

lineaComprimir=$(sed -n '5p' hacerBackup.config.txt)

if [[ "$lineaComprimir" -eq 1 ]]; then
        comprimir=true
        echo "Entre en el if 2"
fi

lineaCrontab=$(sed -n '6p' hacerBackup.config.txt)

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
	echo "No hago crontab"
	eval ./hacerBackup.sh $args
else
	echo "Hago con crontab"
	argsCron="-o \"$directorioOrigen\" -d \"$directorioDestino\" -n \"$nombre\""
	if [[ "$verbose" == true ]]; then
        argsCron+="$args -v"
	fi

	if [[ "$comprimir" == true ]]; then
        argsCron+="$args -nc"
	fi

eval ./hacerBackupCronTab.sh $argsCron
fi


