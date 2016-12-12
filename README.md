# MapPagani

MapPagani est un projet réalisé par *Kostia Chardonnet* et *Sambo Boris Eng* dans le cadre du projet de programmation fonctionnelle (module PF5) de L3 Informatique à l'Université Paris 7 (Diderot).

Le programme correspond à un mini-jeu de puzzle où un joueur doit colorier une carte divisée en plusieurs régions avec seulement 4 uniques couleurs. La coloration complète de la carte telle que deux régions adjacentes sont de couleurs différentes mène à une victoire.

Il est aussi possible de mettre fin au jeu (considéré comme un abandon) en affichant un coloriage correct jouant le rôle de réponse au puzzle.

## Messages administratif (Staff)

**La date limite de soumission est le vendredi 6 janvier à 23h59**

- Code source en OCaml, compilable et utilisable tel quel sous Linux et/ou sur les ordinateurs de l'UFR
- README contenant les noms et indiquant brièvement comment compiler le code source et, si nécessaire, comment utiliser l'exécutable produit
- Un rapport de quelques pages (au plus 5) au format PDF décrivant le projet ainsi que les extensions réalisées, expliquant et justifiant les choix de conception ou d’implémentation
- Tout autre fichier nécessaire à la compilation et à l'exécution : fichiers d’exemples, Makefile

## Installation et utilisation

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

## TODO
- ~~voronoi.ml -> draw_voronoi -> améliorer le try/catch lors du parcours des pixels [Kostia]~~ 
- ~~Réparer la fonction get_list_couleurs : supprimer les doublons, il doit y avoir exactement 4 couleurs [Kostia]~~
- ~~Réparer la fonction get_list_couleurs : combler avec des couleurs pour en avoir 4 [Kostia]~~
- ~~Réparer la fonction adjacences_voronoi : s'assurer qu'elle produit les bons résultats [Kostia]~~
- ~~Séparation des pixels des régions dans plusieurs listes : pour pouvoir colorier qu'une seule région [Kostia]~~
- ~~Fonction check_coloring qui parcours les seeds et leurs voisins et s'arrête puis renvoie true s'il existe un seed qui a un voisin de la même couleur. S'il n'en existe pas on retourne true [Boris]~~
- ~~Mieux découper logiquement le fichier voronoi.ml [Kostia] (draw_voronoi dans mappagani.ml)~~
- Retirer la déclaration de type voronoi dans voronoi.ml et la garder dans voronoi.mli et résoudre les problèmes [Kostia]
- Génération automatique de voronoi [Kostia] A TESTER
- Empêcher la fermeture de la fenêtre lorsqu'il n'y a pas de solution (afficher un message)
- Faire une image quand le joueur a perdu [Boris]
- ~~Recommencer nouvelle partie [Boris]~~
- ~~Supprimer une couleur [Kostia]~~
- ~~**METTRE LE LOGO**~~
- Youpi on a presque fini

## Programme Extrémiste de Peaufinage (PEP)

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
