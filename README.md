# Système de Gestion des Notes (SGN)

**Auteurs** : Cheikhou Camara & Rassoul Beye  
**Module** : Théorie des Langages & Compilation — Master 1 Informatique  
**Année** : 2025-2026

## Description

Ce projet implémente un analyseur lexical et syntaxique pour un langage
de description de notes étudiantes (fichiers .sgn), avec une interface
graphique Python pour visualiser les résultats.

## Structure du projet
sgn_project/

├── src/         → code source C, Flex, Bison

├── gui/         → interface graphique Python

├── tests/       → fichiers de test .sgn

├── rapport/     → rapport technique PDF

└── README.md

## Compilation

```bash
cd src
make
```

## Utilisation en ligne de commande

```bash
cd src
./sgn ../tests/test_valide.sgn
```

## Utilisation avec l'interface graphique

```bash
cd gui
python3 app.py
```

## Fichiers de test disponibles

- `tests/test_valide.sgn` : fichier sans erreurs
- `tests/test_erreur_lex.sgn` : erreurs lexicales
- `tests/test_erreur_syn.sgn` : erreurs syntaxiques
- `tests/test_erreur_sem.sgn` : erreurs sémantiques

## Outils utilisés

- Flex 2.6.4
- Bison 3.8.2
- GCC 15.2.0
- Python 3.14.4
- Tkinter
