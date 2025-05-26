
#!/bin/bash

palabras=("gatos" "perro" "plato" "banco" "silla" "caffa")
secreta=${palabras[$RANDOM % ${#palabras[@]}]}

intentos=0
max_intentos=6

echo "Bienvenido al Wordle!!"
echo "Adivina la palabra de 5 letras. Tenes $max_intentos intentos"

VERDE='\033[1;32m'
AMARILLO='\033[1;33m'
GRIS='\033[1;37m'
RESET='\033[0m'
echo -e "${VERDE}Correcto${RESET}, ${AMARILLO}Lugar Incorrecto y ${GRIS}Incorrecto${RESET}"

while (( intentos<max_intentos)); do
	read -p "Intento $((intentos+1)): " intento

	if [[ ${#intento} -ne 5 ]]; then
		echo "La palabra debe tener 5 letras, volve a inicial"
		continue

	fi

	resultado=""
	for (( i=0; i<5; i++)); do
		letra="${intento:$i:1}"
		if [[ "${letra}" == "${secreta:$i:1}" ]]; then 
			resultado+="${VERDE}${letra}${RESET}"
		elif [[ "$secreta" == *"{letra}"* ]]; then
			resultado+="${AMARILLO}${letra}${RESET}"
		else
			resultado+="${GRIS}${letra}${RESET}"
		fi
	done
	echo -e "$resultado"
	((intentos++))

	if [[ "$intento" == "$secreta" ]]; then
		echo "Correcto!! Adivinaste la palabra '$secreta'"
		exit 0
	fi
done

echo "Perdiste. La palabra secreta era '$secreta'."
