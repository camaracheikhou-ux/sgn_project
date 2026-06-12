# Projet  : Système de Gestion des Notes (SGN)
# Fichier : parser_bridge.py
# Auteurs : Cheikhou Camara & Rassoul Beye
# Date    : Juin 2026
# Description : Pont entre l'interface Python et le binaire C sgn.
#               Lance le binaire, récupère le JSON et les erreurs.

import subprocess
import json
import os

# chemin vers le binaire C compile
BINAIRE = os.path.join(os.path.dirname(__file__), "../src/sgn")

def analyser_fichier(chemin_sgn):
    """
    Lance le binaire sgn sur le fichier .sgn donne.
    Retourne un tuple (donnees, erreurs) :
    - donnees : dictionnaire Python issu du JSON
    - erreurs : liste de messages d'erreur
    """
    # vérifier que le binaire existe
    if not os.path.exists(BINAIRE):
        return None, ["Erreur : binaire sgn introuvable. Lancez 'make' dans src/"]

    # vérifier que le fichier sgn existe
    if not os.path.exists(chemin_sgn):
        return None, ["Erreur : fichier introuvable : " + chemin_sgn]

    # lancer le binaire avec le fichier en argument
    resultat = subprocess.run(
        [BINAIRE, chemin_sgn],
        capture_output=True,
        text=True
    )

    # récupérer les erreurs depuis stderr
    erreurs = []
    if resultat.stderr:
        erreurs = resultat.stderr.strip().split("\n")

    # récupérer et parser le JSON depuis stdout
    donnees = None
    if resultat.stdout:
        try:
            donnees = json.loads(resultat.stdout)
        except json.JSONDecodeError:
            erreurs.append("Erreur : la sortie du binaire n'est pas un JSON valide")

    return donnees, erreurs
