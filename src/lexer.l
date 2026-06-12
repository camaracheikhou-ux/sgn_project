/*
 * Projet  : Système de Gestion des Notes (SGN)
 * Fichier : lexer.l
 * Auteurs : Cheikhou Camara & Rassoul Beye
 * Date    : Juin 2026
 * Description : Analyseur lexical du langage .sgn
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

/* yylineno est activé par l'option yylineno ci-dessous */
%}

/* active le comptage de lignes automatique */
%option yylineno
/* on analyse un seul fichier donc pas besoin de yywrap */
%option noyywrap

%%

"--"[^\n]*    { /* ignorer les commentaires */ }
[ \t\r\n]+    { /* ignorer les espaces et retours à la ligne */ }

"ANNEE"       { return ANNEE; }
"NIVEAU"      { return NIVEAU; }
"ETUDIANT"    { return ETUDIANT; }
"MATRICULE"   { return MATRICULE; }
"NOM"         { return NOM; }
"PRENOM"      { return PRENOM; }
"SEMESTRE"    { return SEMESTRE; }
"MODULE"      { return MODULE; }
"COEF"        { return COEF; }
"NOTE"        { return NOTE; }

"L1"   { return L1; }
"L2"   { return L2; }
"L3"   { return L3; }

"S1"   { return S1; }
"S2"   { return S2; }
"S3"   { return S3; }
"S4"   { return S4; }
"S5"   { return S5; }
"S6"   { return S6; }

\"[^\"]*\" {
    /* on retire les guillemets de la chaine reconnue */
    /* yytext contient la chaine avec guillemets ex: "Algorithmique" */
    /* on copie en sautant le premier guillemet avec yytext+1 */
    yylval.sval = strdup(yytext + 1);
    /* on supprime le dernier guillemet en mettant \0 a la fin */
    yylval.sval[strlen(yylval.sval) - 1] = '\0';
    return STRING;
}

[0-9]+"."[0-9]+ {
    /* nombre reel : on convertit le texte en float avec atof */
    /* cette regle doit etre avant celle des entiers */
    yylval.fval = atof(yytext);
    return REEL;
}

[0-9]+ {
    /* nombre entier : on convertit le texte en int avec atoi */
    yylval.ival = atoi(yytext);
    return ENTIER;
}

"{"   { return '{'; }
"}"   { return '}'; }
":"   { return ':'; }

. {
    /* tout caractere non reconnu : erreur lexicale avec numero de ligne */
    fprintf(stderr, "Erreur lexicale ligne %d : caractere '%s'\n",
            yylineno, yytext);
}

%%
