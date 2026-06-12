/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : ast.c
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Fonctions de création de noeuds AST.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Crée et retourne un nouveau noeud AST */
Noeud *creer_noeud(TypeNoeud type, const char *valeur) {
    Noeud *n = (Noeud *)malloc(sizeof(Noeud));
    if (!n) {
        fprintf(stderr, "Erreur : allocation memoire impossible\n");
        return NULL;
    }
    n->type = type;
    strncpy(n->valeur, valeur, sizeof(n->valeur));
    n->fils  = NULL;
    n->frere = NULL;
    return n;
}
