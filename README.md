# Mappagani

Mappagani est un projet réalisé par *Kostia Chardonnet* et *Sambo Boris Eng* dans le cadre du projet de programmation fonctionnelle (module PF5) de L3 Informatique à l'Université Paris 7 (Diderot).

Le programme est un mini-jeu de puzzle où un joueur doit colorier une carte divisée en plusieurs régions avec seulement 4 couleurs seulement. La coloration complète de la carte telle que deux régions adjacentes sont de couleurs différentes mène à une victoire.

Il est aussi possible de mettre fin au jeu (considéré comme un abandon) en affichant un coloriage correct jouant le rôle de solution du puzzle.

## Installation

1. Télécharger la version la plus récente de *GNU Make*
 - Linux : https://www.gnu.org/software/make/
 - Windows : http://gnuwin32.sourceforge.net/packages/make.htm (d'autres alternatives plus récentes peuvent exister)
 
2. Il faut posséder la version la plus récente d'OCaml et pouvoir compiler les programmes en code natif avec la commande `ocamlopt`.

3. Ouvrir un terminal (Invite de commande 'cmd' sous Windows) et déplacez vous dans le repertoire contenant les fichiers du projet 'Mappagani'.

4. Entrer et exécuter la commande <code>make</code>. Le programme est maintenant compilé.

5. Exécuter le programme avec <code>./mappagani.exe</code> sous *Linux* et <code>mappagani.exe</code> sous Windows.

**Attention** : le programme fonctionne mal sous Windows. Voici la liste des problèmes qui peuvent apparaître :
- Pas de redimentionnement lorsqu'on demande une nouvelle carte
- La fermeture du programme provoque une erreur dans certains cas
- Le haut de la fenêtre du programme n'est pas toujours visible

## Comment jouer

- Cliquez sur une région déjà coloriée pour absorber sa couleur puis appuyez sur une région sans couleur pour la colorier avec la couleur enregistrée. Une fois la carte complétée sans avoir deux régions côte à côte de même couleur un message de victoire s'affiche.
 
- Vous pouvez supprimer le coloriage d'une région en vous positionnant dessus et en appuyant sur la touche [Espace].

- À tout moment vous pouvez choisir de recommencer votre coloriage ou d'abandonner en affichant la solution. Ces options sont disponibles sur le menu.

- Touches supplémentaires :
  + [G] pour afficher le graphe de liaison des régions
  + [O] pour afficher le repère des régions d'origine de la carte
