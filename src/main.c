/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : main.c
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Point d'entrée du programme.
 *               Lance l'analyse et génère la sortie JSON.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboles.h"

/* Fonction définie par Bison */
int yyparse(void);

/* Génération de la sortie JSON sur stdout */
void generer_json(void) {
    int i, j, k, l;

    printf("{\n");
    printf("  \"annee\": \"%s\",\n", programme.annee);
    printf("  \"niveaux\": [\n");

    for (i = 0; i < programme.nb_niveaux; i++) {
        Niveau *n = &programme.niveaux[i];
        printf("    {\n");
        printf("      \"niveau\": \"%s\",\n", n->id);
        printf("      \"etudiants\": [\n");

        for (j = 0; j < n->nb_etudiants; j++) {
            Etudiant *e = &n->etudiants[j];
            printf("        {\n");
            printf("          \"matricule\": \"%s\",\n", e->matricule);
            printf("          \"nom\": \"%s\",\n", e->nom);
            printf("          \"semestres\": [\n");

            for (k = 0; k < e->nb_semestres; k++) {
                Semestre *s = &e->semestres[k];
                printf("            {\n");
                printf("              \"id\": \"%s\",\n", s->id);
                printf("              \"modules\": [\n");

                for (l = 0; l < s->nb_modules; l++) {
                    Module *m = &s->modules[l];
                    printf("                {\"nom\": \"%s\", \"coef\": %d, \"note\": %.1f}",
                           m->nom, m->coef, m->note);
                    if (l < s->nb_modules - 1) printf(",");
                    printf("\n");
                }

                printf("              ],\n");
                printf("              \"moyenne\": %.2f\n", s->moyenne);
                printf("            }");
                if (k < e->nb_semestres - 1) printf(",");
                printf("\n");
            }

            printf("          ],\n");
            printf("          \"moyenne_annuelle\": %.2f,\n", e->moyenne_annuelle);
            printf("          \"mention\": \"%s\",\n", e->mention);
            printf("          \"decision\": \"%s\",\n", e->decision);
            printf("          \"rang\": %d\n", e->rang);
            printf("        }");
            if (j < n->nb_etudiants - 1) printf(",");
            printf("\n");
        }

        printf("      ]\n");
        printf("    }");
        if (i < programme.nb_niveaux - 1) printf(",");
        printf("\n");
    }

    printf("  ],\n");
    printf("  \"erreurs\": []\n");
    printf("}\n");
}

int main(int argc, char *argv[]) {
    /* Initialisation de la structure globale */
    memset(&programme, 0, sizeof(Programme));

    /* Ouverture du fichier .sgn passé en argument */
    if (argc < 2) {
        fprintf(stderr, "Usage : %s fichier.sgn\n", argv[0]);
        return 1;
    }

    extern FILE *yyin;
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Erreur : impossible d'ouvrir '%s'\n", argv[1]);
        return 1;
    }

    /* Lancement de l'analyse syntaxique */
    yyparse();
    fclose(yyin);

    /* Génération du JSON sur stdout */
    generer_json();

    return 0;
}
