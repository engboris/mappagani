# Mappagani

Mappagani est un projet réalisé par *Kostia Chardonnet* et *Sambo Boris Eng* dans le cadre du projet de programmation fonctionnelle (module PF5) de L3 Informatique à l'Université Paris 7 (Diderot).

Le programme est un mini-jeu de puzzle où un joueur doit colorier une carte divisée en plusieurs régions avec seulement 4 couleurs seulement. La coloration complète de la carte telle que deux régions adjacentes sont de couleurs différentes mène à une victoire.

Il est aussi possible de mettre fin au jeu (considéré comme un abandon) en affichant un coloriage correct jouant le rôle de solution du puzzle.

## Installation

1. Télécharger la version la plus récente de *GNU Make*
 - Linux : https://www.gnu.org/software/make/
 - Windows : http://gnuwin32.sourceforge.net/packages/make.htm (d'autres alternatives plus récentes peuvent exister)

2. Ouvrir un terminal (Invite de commande 'cmd' sous Windows) et déplacez vous dans le repertoire contenant les fichiers du projet 'Mappagani'.

3. Entrer et exécuter la commande <code>make</code>. Le programme est maintenant compilé.

4. Exécuter le programme avec <code>./mappagani.exe</code> sous *Linux* et <code>mappagani.exe</code> sous Windows.

**Attention** : le programme fonctionne mal sous Windows. Voici la liste des problèmes qui peuvent apparaître :
- Pas de redimentionnement lorsqu'on demande une nouvelle carte
- La fermeture du programme provoque une erreur
- Le haut de la fenêtre du programme n'est pas visible

## Comment jouer

- Cliquez sur une région déjà coloriée pour absorber sa couleur puis appuyez sur une région différente de celles d'origine pour la colorier avec la couleur enregistrée. Une fois la carte complétée sans avoir deux régions côte à côte de même couleur un message de victoire s'affiche.
 
- Vous pouvez supprimer le coloriage d'une région en vous positionnant dessus et en appuyant sur la touche "Espace".

- À tout moment vous pouvez choisir de recommencer votre coloriage ou d'abandonner en affichant la solution. Ces options sont disponibles sur le menu. 

## Programme Extrémiste de Peaufinage (PEP)

- Retirer toutes les boucles for
- Rendre le code plus fonctionnel si possible
- Utiliser "when" pour les conditions dans le pattern matching
- Déclarer une interface explicite pour chaque code source .ml
- Mettre la description des fonctions dans les interfaces
- Jeux de test complets
- Factoriser le code (pas de répétitions)
- Utiliser la syntaxe let..in pour plus de clarté
- Supprimer les espaces en trop (entre les fonctions notamment)
- Corriger l'indentation
- Commenter le code : en français
- Identifiants des variables et fonctions explicites et en anglais
- Renommage plus approprié pour tous les identifiants
- Rendre la syntaxe plus claire en générale (saut de ligne avant les match..with)
- Ajout d'exceptions et gestion des exceptions plus stricte
- En-tête de commentaire générale pour tous les fichiers + description/spécification
- Mettre des annotations de typage si cela apporte de la précision
- Ne pas écrire de lignes trop longues (découper si besoin)
