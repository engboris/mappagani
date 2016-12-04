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

3. Entrer et exécuter la commande <code>make</code>.

**Attention** : quelques problèmes d'affichages peuvent se produire sous Windows

## TODO
- voronoi.ml -> draw_voronoi -> améliorer le try/catch lors du parcours des pixels [Kostia] 
- ~~Réparer la fonction get_list_couleurs : supprimer les doublons, il doit y avoir exactement 4 couleurs [Kostia]~~
- ~~Réparer la fonction get_list_couleurs : combler avec des couleurs pour en avoir 4 [Kostia]~~
- ~~Réparer la fonction adjacences_voronoi : s'assurer qu'elle produit les bons résultats [Kostia]~~
- Séparation des pixels des régions dans plusieurs listes : pour pouvoir colorier qu'une seule région [Kostia]
- Fonction check_coloring qui parcours les seeds et leurs voisins et s'arrête puis renvoie true s'il existe un seed qui a un voisin de la même couleur. S'il n'en existe pas on retourne true [Kostia]
- Mieux découper logiquement le fichier voronoi.ml [Kostia]
- Optmisations possibles [Kostia] :
  * Calculer les frontières dans region_voronoi et si on a un couple de pixel de couleurs différentes, ajouter ce voisinage dans une liste (sans doublons) puis à partir de la liste obtenue on a une fonction qui va calculer la matrice d'adjacence en temps linéaire en parcourant la liste. On peut utiliser des fonctions auxiliaire genre une grosse fonction qui renvoie (regions, table de voisinage) et regions_voronoi va juste récupérer le premier élément du couple de cette fonction auxiliaire et adjacence_voronoi va récupérer la table pour calculer l'adjacence.

## Programme Extrémiste de Peaufinage (PEP)

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
