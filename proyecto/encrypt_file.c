#include <openssl/evp.h>
#include <openssl/err.h>  // Para el handleErrors().
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <openssl/rand.h>  // Para la operacion de RAND_bytes().
#include <openssl/sha.h>   // Para convertir a la clave en un SHA-256.

void handleErrors(void) {
    ERR_print_errors_fp(stderr);
    abort();
}

int encrypt_file(const char *input_path, const char *output_path, const unsigned char *key) {
    FILE *in_file = fopen(input_path, "rb");
    if (!in_file) {
        perror("Error al abrir archivo de entrada");
        return 1;
    }

    FILE *out_file = fopen(output_path, "wb");
    if (!out_file) {
        perror("Error al crear archivo de salida");
        fclose(in_file);
        return 1;
    }

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    unsigned char iv[16];
    if (1 != RAND_bytes(iv, sizeof(iv))) handleErrors();
    fwrite(iv, 1, sizeof(iv), out_file); // Se guarda al principio del archivo.

    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
        handleErrors();

    unsigned char buffer[1024];
    unsigned char cipher_buffer[1024 + EVP_MAX_BLOCK_LENGTH];  // algo más grande para datos cifrados
    int len, cipher_len;

    while ((len = fread(buffer, 1, sizeof(buffer), in_file)) > 0) {
        if (1 != EVP_EncryptUpdate(ctx, cipher_buffer, &cipher_len, buffer, len))
            handleErrors();
        fwrite(cipher_buffer, 1, cipher_len, out_file);
	printf("Cifrado/escrito %d bytes\n", cipher_len);

    }

    if (1 != EVP_EncryptFinal_ex(ctx, cipher_buffer, &cipher_len))
        handleErrors();
    fwrite(cipher_buffer, 1, cipher_len, out_file);

    EVP_CIPHER_CTX_free(ctx);
    fclose(in_file);
    fclose(out_file);

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Uso: %s <archivo_entrada> <archivo_salida> <clave>\n", argv[0]);
        return 1;
    }

    printf("Archivo de entrada: %s\n", argv[1]);
    printf("Archivo de salida: %s\n", argv[2]);
	
	// La clave ahora se le paso por afuera, y la convierto a SHA-256.
    unsigned char key[32];
    SHA256((const unsigned char *)argv[3], strlen(argv[3]), key);

    if (encrypt_file(argv[1], argv[2], key) != 0) {
        fprintf(stderr, "Error al cifrar archivo.\n");
        return 1;
    }

    printf("Archivo cifrado correctamente.\n");
    return 0;
   
}
