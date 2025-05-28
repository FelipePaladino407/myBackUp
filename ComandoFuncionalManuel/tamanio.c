#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
	if (argc != 2) {
		fprintf(stderr, "Uso: %s <rutaArchivo>\n", argv[0]);
		return 1;
	}

	FILE *archivo = fopen(argv[1], "rb");
	if (archivo == NULL) {
		perror("Error, no se pudo abrir el archivo");
		return 1;

	}

	fseek(archivo, 0, SEEK_END);
	long tam = ftell(archivo);
	fclose(archivo);
	printf("%ld\n", tam);
	return 0;
}
