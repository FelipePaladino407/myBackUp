
#!/bin/bash

palabras=( "sistemas" "caffa" "scheduller" "drivers" "ram" "rom" "cpu" "kernell" "procesos" "recursos" ")
secreta=${palabras[$RANDOM % ${#palabras[@]}]}

intentos=0
max_intentos=6

echo "Bienvenido al Wordle!!"
echo "Adivina la palabra de ${#secreta} letras. Tenes $max_intentos intentos"

VERDE='\033[1;32m'
AMARILLO='\033[1;33m'
GRIS='\033[1;37m'
RESET='\033[0m'
echo -e "${VERDE}Correcto${RESET}, ${AMARILLO}Lugar Incorrecto y ${GRIS}Incorrecto${RESET}"

while (( intentos<max_intentos)); do
	read -p "Intento $((intentos+1)): " intento

	if [[ ${#intento} -ne ${#secreta} ]]; then
		echo "La palabra debe tener ${#secreta} letras."
		continue

	fi
	declare -a usada
	resultado=()
	largo=${#secreta}
	for ((i=0; i<largo; i++)); do usada[i]=0; done


	for (( i=0; i<largo; i++)); do
		letra="${intento:$i:1}"
		if [[ "${letra}" == "${secreta:$i:1}" ]]; then 
			resultado[i]="${VERDE}${letra}${RESET}"
			usada[i]=1
		fi
	done

	for (( i=0; i<largo; i++)); do
		if [[ -n "${resultado[i]}" ]]; then continue; fi
		letra="${intento:$i:1}"
		encontrado=false

		for ((j=0; j<largo; j++)); do
	                if [[ "${letra}" == "${secreta:$j:1}" && "${usada[j]}" -eq 0 ]]; then 
				 resultado[i]="${AMARILLO}${letra}${RESET}"
				 usada[j]=1
			 	 encontrado=true
				 break
			fi
		done

		if ! $encontrado; then
			resultado[i]="${GRIS}${letra}${RESET}"
		fi
	done
	echo -e "${resultado[*]}"
	((intentos++))

	if [[ "$intento" == "$secreta" ]]; then
		echo "Correcto!! Adivinaste la palabra '$secreta'"
		exit 0
	fi
done

echo "Perdiste. La palabra secreta era '$secreta'."
