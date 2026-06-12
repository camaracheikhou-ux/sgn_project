/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : ast.h
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Définition des types de noeuds de l'AST.
 *               Dans ce projet on utilise une table de symboles
 *               (symboles.h) mais on definit l'AST pour reference.
 */

#ifndef AST_H
#define AST_H

/* Types de noeuds possibles dans l'arbre */
typedef enum {
    NOEUD_PROGRAMME,
    NOEUD_NIVEAU,
    NOEUD_ETUDIANT,
    NOEUD_SEMESTRE,
    NOEUD_MODULE
} TypeNoeud;

/* Structure d'un noeud de l'AST */
typedef struct Noeud {
    TypeNoeud    type;       /* type du noeud                */
    char         valeur[100];/* valeur associee au noeud     */
    struct Noeud *fils;      /* premier fils                 */
    struct Noeud *frere;     /* frere suivant (meme niveau)  */
} Noeud;

/* Creation d'un nouveau noeud */
Noeud *creer_noeud(TypeNoeud type, const char *valeur);

#endif
