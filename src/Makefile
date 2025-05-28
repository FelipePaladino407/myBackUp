CC = gcc
CFLAGS = -Wall -O2
LIBS = -lcrypto

all: encryptor

encryptor: encryptor.c
	$(CC) $(CFLAGS) -o encryptor encryptor.c $(LIBS)

clean:
	rm -f encryptor
