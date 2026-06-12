/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : symboles.h
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Définition des structures de données du projet.
 */

#ifndef SYMBOLES_H
#define SYMBOLES_H

#define MAX_NIVEAUX    3
#define MAX_ETUDIANTS  100
#define MAX_SEMESTRES  6
#define MAX_MODULES    20

/* Structure d'un module */
typedef struct {
    char  nom[100];
    int   coef;
    float note;
} Module;

/* Structure d'un semestre */
typedef struct {
    char   id[3];
    Module modules[MAX_MODULES];
    int    nb_modules;
    float  moyenne;
} Semestre;

/* Structure d'un étudiant */
typedef struct {
    char     matricule[50];
    char     nom[100];
    char     prenom[100];
    Semestre semestres[MAX_SEMESTRES];
    int      nb_semestres;
    float    moyenne_annuelle;
    char     mention[20];
    char     decision[10];
    int      rang;
} Etudiant;

/* Structure d'un niveau */
typedef struct {
    char     id[3];
    Etudiant etudiants[MAX_ETUDIANTS];
    int      nb_etudiants;
} Niveau;

/* Structure globale du programme */
typedef struct {
    char   annee[20];
    Niveau niveaux[MAX_NIVEAUX];
    int    nb_niveaux;
} Programme;

/* Variable globale accessible depuis tous les fichiers */
extern Programme programme;

#endif
