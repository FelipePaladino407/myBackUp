CC = gcc
CFLAGS = -Wall -Wextra -pedantic
LIBS = -lssl -lcrypto

all: encrypt_file decrypt_file

encrypt_file: encrypt_file.c
	$(CC) $(CFLAGS) -o encrypt_file encrypt_file.c $(LIBS)

decrypt_file: decrypt_file.c
	$(CC) $(CFLAGS) -o decrypt_file decrypt_file.c $(LIBS)

clean:
	rm -f encrypt_file decrypt_file
