# Projet  : Système de Gestion des Notes (SGN)
# Fichier : interface.py
# Auteurs : Cheikhou Camara & Rassoul Beye
# Date    : Juin 2026
# Description : Widgets Tkinter de l'interface graphique.

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import csv
import os
from parser_bridge import analyser_fichier

class InterfaceSGN:

    def __init__(self, root):
        self.root = root
        self.root.title("Système de Gestion des Notes - SGN")
        self.root.geometry("1100x700")
        self.fichier_courant = None
        self.construire_interface()

    def construire_interface(self):
        # --- Barre de titre ---
        titre = tk.Label(self.root, text="Système de Gestion des Notes",
                         font=("Arial", 16, "bold"), pady=10)
        titre.pack()

        # --- Barre de boutons ---
        barre = tk.Frame(self.root)
        barre.pack(fill=tk.X, padx=10, pady=5)

        tk.Button(barre, text="Ouvrir fichier .sgn",
                  command=self.ouvrir_fichier, bg="#4CAF50", fg="white",
                  padx=10).pack(side=tk.LEFT, padx=5)

        tk.Button(barre, text="Analyser",
                  command=self.lancer_analyse, bg="#2196F3", fg="white",
                  padx=10).pack(side=tk.LEFT, padx=5)

        tk.Button(barre, text="Exporter CSV",
                  command=self.exporter_csv, bg="#FF9800", fg="white",
                  padx=10).pack(side=tk.LEFT, padx=5)

        tk.Button(barre, text="Exporter TXT",
                  command=self.exporter_txt, bg="#9C27B0", fg="white",
                  padx=10).pack(side=tk.LEFT, padx=5)

        # --- Zone principale : éditeur + résultats ---
        zone_principale = tk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        zone_principale.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)

        # --- Éditeur de texte (gauche) ---
        cadre_editeur = tk.LabelFrame(zone_principale, text="Éditeur de fichier .sgn")
        zone_principale.add(cadre_editeur, width=400)

        self.editeur = tk.Text(cadre_editeur, font=("Courier", 11), wrap=tk.NONE)
        scroll_edit = tk.Scrollbar(cadre_editeur, command=self.editeur.yview)
        self.editeur.config(yscrollcommand=scroll_edit.set)
        scroll_edit.pack(side=tk.RIGHT, fill=tk.Y)
        self.editeur.pack(fill=tk.BOTH, expand=True)

        # --- Zone résultats (droite) ---
        cadre_resultats = tk.LabelFrame(zone_principale, text="Résultats")
        zone_principale.add(cadre_resultats)

        # tableau des résultats
        colonnes = ("Matricule", "Nom", "Niveau", "Moy. S1", "Moy. S2",
                    "Moy. Annuelle", "Mention", "Décision", "Rang")
        self.tableau = ttk.Treeview(cadre_resultats, columns=colonnes,
                                     show="headings", height=15)
        for col in colonnes:
            self.tableau.heading(col, text=col)
            self.tableau.column(col, width=100, anchor=tk.CENTER)

        scroll_tab = tk.Scrollbar(cadre_resultats, command=self.tableau.yview)
        self.tableau.config(yscrollcommand=scroll_tab.set)
        scroll_tab.pack(side=tk.RIGHT, fill=tk.Y)
        self.tableau.pack(fill=tk.BOTH, expand=True)

        # --- Zone des erreurs (bas) ---
        cadre_erreurs = tk.LabelFrame(self.root, text="Erreurs détectées")
        cadre_erreurs.pack(fill=tk.X, padx=10, pady=5)

        self.zone_erreurs = tk.Text(cadre_erreurs, height=5,
                                     font=("Courier", 10),
                                     bg="#ffeeee", fg="red",
                                     state=tk.DISABLED)
        self.zone_erreurs.pack(fill=tk.X)

        # stocker les données pour l'export
        self.donnees_resultats = []

    def ouvrir_fichier(self):
        # ouvrir un fichier .sgn via une boite de dialogue
        chemin = filedialog.askopenfilename(
            title="Ouvrir un fichier .sgn",
            filetypes=[("Fichiers SGN", "*.sgn"), ("Tous les fichiers", "*.*")]
        )
        if chemin:
            self.fichier_courant = chemin
            with open(chemin, "r", encoding="utf-8") as f:
                contenu = f.read()
            # afficher le contenu dans l'éditeur
            self.editeur.delete("1.0", tk.END)
            self.editeur.insert("1.0", contenu)

    def lancer_analyse(self):
        # sauvegarder le contenu de l'éditeur dans un fichier temporaire
        if not self.fichier_courant:
            messagebox.showwarning("Attention", "Veuillez d'abord ouvrir un fichier .sgn")
            return

        # sauvegarder les modifications de l'éditeur
        contenu = self.editeur.get("1.0", tk.END)
        with open(self.fichier_courant, "w", encoding="utf-8") as f:
            f.write(contenu)

        # appeler le binaire C via parser_bridge
        donnees, erreurs = analyser_fichier(self.fichier_courant)

        # afficher les erreurs
        self.afficher_erreurs(erreurs)

        # afficher les résultats dans le tableau
        if donnees:
            self.afficher_resultats(donnees)

    def afficher_erreurs(self, erreurs):
        # activer la zone, effacer, écrire les erreurs, désactiver
        self.zone_erreurs.config(state=tk.NORMAL)
        self.zone_erreurs.delete("1.0", tk.END)
        if erreurs:
            for err in erreurs:
                self.zone_erreurs.insert(tk.END, err + "\n")
        else:
            self.zone_erreurs.insert(tk.END, "Aucune erreur détectée.\n")
            self.zone_erreurs.config(fg="green")
        self.zone_erreurs.config(state=tk.DISABLED)

    def afficher_resultats(self, donnees):
        # vider le tableau
        for row in self.tableau.get_children():
            self.tableau.delete(row)

        self.donnees_resultats = []

        # parcourir les niveaux et étudiants
        for niveau in donnees.get("niveaux", []):
            nom_niveau = niveau["niveau"]
            for etu in niveau.get("etudiants", []):
                semestres = etu.get("semestres", [])

                # récupérer les moyennes semestrielles
                moy_s1 = ""
                moy_s2 = ""
                if len(semestres) >= 1:
                    moy_s1 = f"{semestres[0]['moyenne']:.2f}"
                if len(semestres) >= 2:
                    moy_s2 = f"{semestres[1]['moyenne']:.2f}"

                ligne = (
                    etu["matricule"],
                    etu["nom"],
                    nom_niveau,
                    moy_s1,
                    moy_s2,
                    f"{etu['moyenne_annuelle']:.2f}",
                    etu["mention"],
                    etu["decision"],
                    etu["rang"]
                )
                self.tableau.insert("", tk.END, values=ligne)
                self.donnees_resultats.append(ligne)

    def exporter_csv(self):
        if not self.donnees_resultats:
            messagebox.showwarning("Attention", "Aucun résultat à exporter")
            return
        chemin = filedialog.asksaveasfilename(
            defaultextension=".csv",
            filetypes=[("Fichier CSV", "*.csv")]
        )
        if chemin:
            with open(chemin, "w", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow(["Matricule", "Nom", "Niveau", "Moy S1",
                                  "Moy S2", "Moy Annuelle", "Mention",
                                  "Decision", "Rang"])
                writer.writerows(self.donnees_resultats)
            messagebox.showinfo("Export", "Fichier CSV exporté avec succès")

    def exporter_txt(self):
        if not self.donnees_resultats:
            messagebox.showwarning("Attention", "Aucun résultat à exporter")
            return
        chemin = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Fichier texte", "*.txt")]
        )
        if chemin:
            with open(chemin, "w", encoding="utf-8") as f:
                f.write("RÉSULTATS - SYSTÈME DE GESTION DES NOTES\n")
                f.write("=" * 60 + "\n\n")
                for ligne in self.donnees_resultats:
                    f.write(f"Matricule    : {ligne[0]}\n")
                    f.write(f"Nom          : {ligne[1]}\n")
                    f.write(f"Niveau       : {ligne[2]}\n")
                    f.write(f"Moy S1       : {ligne[3]}\n")
                    f.write(f"Moy S2       : {ligne[4]}\n")
                    f.write(f"Moy Annuelle : {ligne[5]}\n")
                    f.write(f"Mention      : {ligne[6]}\n")
                    f.write(f"Décision     : {ligne[7]}\n")
                    f.write(f"Rang         : {ligne[8]}\n")
                    f.write("-" * 40 + "\n")
            messagebox.showinfo("Export", "Fichier TXT exporté avec succès")
