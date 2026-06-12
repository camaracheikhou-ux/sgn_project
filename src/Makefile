# Projet  : Système de Gestion des Notes (SGN)
# Fichier : Makefile
# Auteurs : Cheikhou Camara & Rassoul Beye
# Date    : Juin 2026
# Description : Compilation automatique du projet

CC     = gcc
CFLAGS = -Wall -g

all: sgn

# Étape 1 : Bison génère parser.tab.c et parser.tab.h
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Étape 2 : Flex génère lex.yy.c
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Étape 3 : Compilation finale
sgn: parser.tab.c lex.yy.c main.c
	$(CC) $(CFLAGS) -o sgn parser.tab.c lex.yy.c main.c -lfl -lm

# Nettoyage des fichiers générés
clean:
	rm -f parser.tab.c parser.tab.h lex.yy.c sgn
