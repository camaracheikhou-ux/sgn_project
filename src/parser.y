/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : parser.y
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Analyseur syntaxique et sémantique du langage .sgn
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboles.h"

/* yylineno vient du lexer */
extern int yylineno;

/* structure globale qui contient toutes les donnees parsees */
Programme programme;

/* indices pour savoir ou on en est pendant l'analyse */
int niv = -1;  /* indice du niveau courant   */
int etu = -1;  /* indice de l'etudiant courant */
int sem = -1;  /* indice du semestre courant  */

/* prototypes des fonctions */
void yyerror(const char *msg);
int  yylex(void);
float moyenne_semestre(Semestre *s);
float moyenne_annuelle(Etudiant *e);
void  donner_mention(Etudiant *e);
void  calculer_rangs(Niveau *n);
int   doublon_matricule(Niveau *n, const char *mat);
%}

/* union : definit les types de valeurs possibles pour yylval */
%union {
    int   ival;  /* entier  */
    float fval;  /* reel    */
    char *sval;  /* chaine  */
}

/* tokens sans valeur */
%token ANNEE NIVEAU ETUDIANT MATRICULE NOM PRENOM
%token SEMESTRE MODULE COEF NOTE
%token L1 L2 L3
%token S1 S2 S3 S4 S5 S6

/* tokens avec valeur : Bison sait quel champ de yylval utiliser */
%token <sval> STRING
%token <ival> ENTIER
%token <fval> REEL

%%

/* --- Grammaire conforme a la BNF du sujet --- */

programme
    : ANNEE STRING liste_niveaux
      {
          /* on stocke l'annee academique */
          strncpy(programme.annee, $2, sizeof(programme.annee));
          free($2);
      }
    ;

liste_niveaux
    : niveau
    | liste_niveaux niveau
    ;

niveau
    : NIVEAU id_niveau '{' liste_etudiants '}'
      {
          /* fin du niveau : on calcule les rangs des etudiants */
          calculer_rangs(&programme.niveaux[niv]);
      }
    ;

id_niveau
    : L1
      {
          /* chercher si L1 existe deja, sinon on le cree */
          int i, trouve = -1;
          for (i = 0; i < programme.nb_niveaux; i++)
              if (strcmp(programme.niveaux[i].id, "L1") == 0) { trouve = i; break; }
          if (trouve == -1) {
              niv = programme.nb_niveaux;
              strcpy(programme.niveaux[niv].id, "L1");
              programme.niveaux[niv].nb_etudiants = 0;
              programme.nb_niveaux++;
          } else {
              niv = trouve;
          }
      }
    | L2
      {
          int i, trouve = -1;
          for (i = 0; i < programme.nb_niveaux; i++)
              if (strcmp(programme.niveaux[i].id, "L2") == 0) { trouve = i; break; }
          if (trouve == -1) {
              niv = programme.nb_niveaux;
              strcpy(programme.niveaux[niv].id, "L2");
              programme.niveaux[niv].nb_etudiants = 0;
              programme.nb_niveaux++;
          } else {
              niv = trouve;
          }
      }
    | L3
      {
          int i, trouve = -1;
          for (i = 0; i < programme.nb_niveaux; i++)
              if (strcmp(programme.niveaux[i].id, "L3") == 0) { trouve = i; break; }
          if (trouve == -1) {
              niv = programme.nb_niveaux;
              strcpy(programme.niveaux[niv].id, "L3");
              programme.niveaux[niv].nb_etudiants = 0;
              programme.nb_niveaux++;
          } else {
              niv = trouve;
          }
      }
    ;

liste_etudiants
    : etudiant
    | liste_etudiants etudiant
    ;

etudiant
    : ETUDIANT '{' champs_etudiant liste_semestres '}'
      {
          /* fin de l'etudiant : calcul moyenne annuelle et mention */
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          e->moyenne_annuelle = moyenne_annuelle(e);
          donner_mention(e);
      }
    ;

champs_etudiant
    : MATRICULE ':' STRING NOM ':' STRING PRENOM ':' STRING
      {
          Niveau *n = &programme.niveaux[niv];

          /* verification semantique : doublon de matricule */
          if (doublon_matricule(n, $3))
              fprintf(stderr,
                  "Erreur semantique : matricule '%s' deja utilise dans ce niveau\n", $3);

          /* ajout de l'etudiant dans le niveau courant */
          etu = n->nb_etudiants;
          Etudiant *e = &n->etudiants[etu];
          strncpy(e->matricule, $3, sizeof(e->matricule));
          strncpy(e->nom,       $6, sizeof(e->nom));
          strncpy(e->prenom,    $9, sizeof(e->prenom));
          e->nb_semestres = 0;
          n->nb_etudiants++;
          free($3); free($6); free($9);
      }
    ;

liste_semestres
    : semestre
    | liste_semestres semestre
    ;

semestre
    : SEMESTRE id_semestre '{' liste_modules '}'
      {
          /* fin du semestre : calcul de la moyenne ponderee */
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          e->semestres[sem].moyenne = moyenne_semestre(&e->semestres[sem]);
      }
    ;

/* verification semantique : chaque semestre doit etre dans le bon niveau */
id_semestre
    : S1
      {
          if (strcmp(programme.niveaux[niv].id, "L1") != 0)
              fprintf(stderr, "Erreur semantique : S1 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S1");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    | S2
      {
          if (strcmp(programme.niveaux[niv].id, "L1") != 0)
              fprintf(stderr, "Erreur semantique : S2 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S2");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    | S3
      {
          if (strcmp(programme.niveaux[niv].id, "L2") != 0)
              fprintf(stderr, "Erreur semantique : S3 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S3");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    | S4
      {
          if (strcmp(programme.niveaux[niv].id, "L2") != 0)
              fprintf(stderr, "Erreur semantique : S4 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S4");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    | S5
      {
          if (strcmp(programme.niveaux[niv].id, "L3") != 0)
              fprintf(stderr, "Erreur semantique : S5 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S5");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    | S6
      {
          if (strcmp(programme.niveaux[niv].id, "L3") != 0)
              fprintf(stderr, "Erreur semantique : S6 interdit dans %s\n",
                      programme.niveaux[niv].id);
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          sem = e->nb_semestres;
          strcpy(e->semestres[sem].id, "S6");
          e->semestres[sem].nb_modules = 0;
          e->nb_semestres++;
      }
    ;

liste_modules
    : module
    | liste_modules module
    ;

module
    : MODULE STRING COEF ENTIER NOTE REEL
      {
          Etudiant *e = &programme.niveaux[niv].etudiants[etu];
          Semestre *s = &e->semestres[sem];

          /* verification semantique : note entre 0 et 20 */
          if ($6 < 0.0 || $6 > 20.0)
              fprintf(stderr,
                  "Erreur semantique : note %.2f invalide (doit etre entre 0 et 20)\n", $6);

          /* verification semantique : coefficient >= 1 */
          if ($4 < 1)
              fprintf(stderr,
                  "Erreur semantique : coefficient %d invalide (minimum 1)\n", $4);

          /* ajout du module dans le semestre courant */
          /* $2=nom $4=coef $6=note */
          strncpy(s->modules[s->nb_modules].nom, $2, 100);
          s->modules[s->nb_modules].coef = $4;
          s->modules[s->nb_modules].note = $6;
          s->nb_modules++;
          free($2);
      }
    ;

%%

/* --- Calcul de la moyenne ponderee d'un semestre --- */
/* formule : somme(coef * note) / somme(coef)          */
float moyenne_semestre(Semestre *s) {
    float total_notes = 0, total_coef = 0;
    int i;
    if (s->nb_modules == 0) return 0;
    for (i = 0; i < s->nb_modules; i++) {
        total_notes += s->modules[i].coef * s->modules[i].note;
        total_coef  += s->modules[i].coef;
    }
    return total_notes / total_coef;
}

/* --- Calcul de la moyenne annuelle --- */
/* formule : moyenne des moyennes de chaque semestre   */
float moyenne_annuelle(Etudiant *e) {
    float total = 0;
    int i;
    if (e->nb_semestres == 0) return 0;
    for (i = 0; i < e->nb_semestres; i++)
        total += e->semestres[i].moyenne;
    return total / e->nb_semestres;
}

/* --- Attribution de la mention selon la moyenne annuelle --- */
void donner_mention(Etudiant *e) {
    float m = e->moyenne_annuelle;
    if (m >= 16.0) {
        strcpy(e->mention, "Tres Bien");
        strcpy(e->decision, "Admis");
    } else if (m >= 14.0) {
        strcpy(e->mention, "Bien");
        strcpy(e->decision, "Admis");
    } else if (m >= 12.0) {
        strcpy(e->mention, "Assez Bien");
        strcpy(e->decision, "Admis");
    } else if (m >= 10.0) {
        strcpy(e->mention, "Passable");
        strcpy(e->decision, "Admis");
    } else {
        strcpy(e->mention, "");
        strcpy(e->decision, "Ajourne");
    }
}

/* --- Calcul des rangs par tri des moyennes decroissantes --- */
void calculer_rangs(Niveau *n) {
    int i, j;
    Etudiant tmp;
    for (i = 0; i < n->nb_etudiants - 1; i++) {
        for (j = i + 1; j < n->nb_etudiants; j++) {
            if (n->etudiants[j].moyenne_annuelle > n->etudiants[i].moyenne_annuelle) {
                tmp             = n->etudiants[i];
                n->etudiants[i] = n->etudiants[j];
                n->etudiants[j] = tmp;
            }
        }
    }
    for (i = 0; i < n->nb_etudiants; i++)
        n->etudiants[i].rang = i + 1;
}

/* --- Verification si un matricule existe deja dans un niveau --- */
int doublon_matricule(Niveau *n, const char *mat) {
    int i;
    for (i = 0; i < n->nb_etudiants; i++)
        if (strcmp(n->etudiants[i].matricule, mat) == 0) return 1;
    return 0;
}

/* --- Fonction d'erreur syntaxique obligatoire pour Bison --- */
void yyerror(const char *msg) {
    fprintf(stderr, "Erreur syntaxique ligne %d : %s\n", yylineno, msg);
}
