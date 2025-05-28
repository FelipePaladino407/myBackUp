#include <openssl/evp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <openssl/sha.h>

void handleErrors(void) {
    ERR_print_errors_fp(stderr);
    abort();
}

int decrypt_file(const char *input_path, const char *output_path, const unsigned char *key) {
    FILE *in_file = fopen(input_path, "rb");
    FILE *out_file = fopen(output_path, "wb");
    if (!in_file || !out_file) {
        perror("Error al abrir archivos");
        return 1;
    }

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

	// EL IV QUEDO GUARDADO EN EL ARCHIVO DE ENTRADA.
    unsigned char iv[16];
    if (fread(iv, 1, sizeof(iv), in_file) != sizeof(iv)) {
	fprintf(stderr, "Error al leer el IV del archivo.\n");
	return 1;
}

    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
        handleErrors();

    unsigned char buffer[1024];
    unsigned char plaintext[1024 + EVP_MAX_BLOCK_LENGTH];
    int len, plaintext_len = 0;

    while ((len = fread(buffer, 1, sizeof(buffer), in_file)) > 0) {
        int out_len;
        if (1 != EVP_DecryptUpdate(ctx, plaintext, &out_len, buffer, len))
            handleErrors();

        fwrite(plaintext, 1, out_len, out_file);
        plaintext_len += out_len;
    }

    int final_len;
    if (1 != EVP_DecryptFinal_ex(ctx, plaintext, &final_len)) {
    	fprintf(stderr, "Error: la clave es incorrecta o el archivo esta corrupto. ABORTAR! ABORTAR!. \n");
 	EVP_CIPHER_CTX_free(ctx);
	fclose(in_file);
	fclose(out_file);
	return 1;
}

    fwrite(plaintext, 1, final_len, out_file);
    plaintext_len += final_len;

    EVP_CIPHER_CTX_free(ctx);
    fclose(in_file);
    fclose(out_file);

    printf("Archivo descifrado correctamente (%d bytes).\n", plaintext_len);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Uso: %s <archivo_cifrado> <archivo_salida>\n", argv[0]);
        return 1;
    }

    printf("Archivo cifrado: %s\n", argv[1]);
    printf("Archivo de salida: %s\n", argv[2]);

    unsigned char key[32];
    SHA256((const unsigned char *)argv[3], strlen(argv[3]), key);

    return decrypt_file(argv[1], argv[2], key);
}
