# Projet  : Système de Gestion des Notes (SGN)
# Fichier : app.py
# Auteurs : Cheikhou Camara & Rassoul Beye
# Date    : Juin 2026
# Description : Point d'entrée de l'interface graphique.
#               Lancer avec : python3 app.py

import tkinter as tk
import sys
import os

# ajouter le dossier gui au path pour importer interface et parser_bridge
sys.path.insert(0, os.path.dirname(__file__))

from interface import InterfaceSGN

if __name__ == "__main__":
    root = tk.Tk()
    app = InterfaceSGN(root)
    root.mainloop()
