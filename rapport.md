Quentin Wattelle, Marceau CARRO
# Rapport de Projet de PFA : Jeu de plateforme "At What Cost"

## Introduction
Pour ce projet, il nous était demandé de programmer un jeu en OCaml en se servant des bibliothèques Gfx et ECS, et en implémentant des aspects classiques des jeux vidéos tel que la gravité.
Nous nous sommes alors mis d'accord sur la réalisation d'un jeu de plateforme dans un univers d'agent secret a deux joueurs : At What Cost.

## Description des éléments du projet

Nous allons à présent expliquer ce que nous avons implanté, en séparant par aspects de l'architecture Entité-Composant-Système.
Chaque aspect sera détaillé dans sa propre partie.

#### Composants :
Les composants représentent les différents outils qui vont permettre aux entités d'être correctement représentées auprès des systèmes (dessin, collisions, forces...).
Voici la liste de ceux-ci:

* `tagged` : Agit comme une étiquette, permet de reconnaitre une entité lors d'un pattern-matching.
* `position` : Contient le cvecteur de position de l'entité.
* `velocity` : Contient le vecteur vitesse de l'entité.
* `mass` : Contient la masse de l'entité, qui influe sur les collisions entre les entités.
* `elasticity` : Inspiré du TP03, et contient l'élasticité de l'entité : c'est la force avec laquelle il va rebondir lorsqu'il entrera en collision avec d'autres entités.
* `sum_forces` : Représente la somme des forces qui s'éxercent sur l'entité.
* `box` : Contient les dimensions de l'entité, pour les collisions ou encore le dessin.
* `texture` : Contient un tableau de tableau de Textures.
Dans le cas des entités comme le joueur ou les ennemis, chaque sous-array contiendra l'ensemble des images correspondant à une animation de l'entité (marche, course...).
Dans le cas du décor, seul le premier sous-array sert, et contient les images du niveau en cours.
* `current_sprite_set` : Indique l'indice du sous-array dans lequel se trouve l'image actuellement utilisée par le système de dessin.
Par exemple, pour le joueur et les ennemis, il indique quel animation est actuellement affichée (par exemple, le saut).
* `current_sprite` : Indique l'indice de l'image actuellement affichée au sein de du sous-array d'indice `current_sprite_set` du composant `texture`.
En reprenant l'exemple précédent, si nous sommes en train de courir, on sera donc en train d'afficher une des images du sous-array correspondant.
* `last_dt` : Inspiré du TP01, et contient le temps écoulé entre le début de l'exécution du programme et la dernière fois que le l'image actuelle affichée pour l'entité a été changée.
Cela nous permet de controler la vitesse à laquelle les animations jouent.
* `is_airborne` : Pour les entités capable de sauter, indique si ces derniers sont en l'air. Si c'est le cas, leur action de saut est désactivée jusqu'à ce qu'ils retouchent le sol.

#### Entités :
Continuons avec les entités, les différents éléments qui vont se retrouver à intéragir avec le joueur via les différents systèmes.
Ils héritent de nombreux composants pour mieux gérer leurs interactions avec les systèmes auxquels ils sont inscrits et qui seront détaillés dans la section systèmes. 

Nous allons surtout nous concentrer sur les fonctions du fichier entité correspondant.

Chaque entité possèdent en commun :
* Une fonction de création qui va être utilisé par `game.ml` pour initialiser les entités.
* Un ou des "getters", qui vont récupérer ces entités crées via l'objet `Global`.
* Une fonction de chargement de lot d'image (`load_spriteset` pour Player et Enemy, ou `load_tile_set` pour Decor) :
Pour Player et Enemy, elle charge un sprite set (un ensemble d'images correspondant à une animation) dans le sous-array de texture indiqué.
Pour Decor, elle charge dans le sous-array d'indice 1 l'ensemble des images du niveau.
Nous nous sommes inspirés du TP01 en allant d'abord chercher les noms d'images nécéssaires à l'animations dans un fichier, puis en allant chercher les images elles-mêmes à partir de ces noms.
après avoir découpé la chaîne de caractère du fichier en une liste de noms d'images. Enfin, après s'être assuré que toutes les images soient prêtes, on les met dans un array qui va remplacer le sous-array initialement "vide" (il ne contient qu'une couleur unie).
* `load_textures` : Répète le travail pour toutes les entités de ce type présentes dans `Global`.  
Par la suite, la fonction update du système Draw pourra afficher les images correctement.

Faisons à présent l'inventaire des entités et de leurs fonctions uniques :

* Player : Le joueur est le personnage principal de notre jeu, ici représenté par un sprite d'agent secret. Il est capable de plusieurs actions basiques, soit la marche, la course et le saut. Voici ses fonctions "uniques":
    - `stop_players` : Arrête les entités Player en mettant leur vecteur vitesse à 0.
    - `move_player` : Agit comme un "setter" de vitesse pour les joueurs et permet le déplacement, on s'en sert dans `input.ml` pour déplacer les joueurs quand on appuie sur la touche correspondante.

* Enemy : Les enemis sont la menace principale du jeu, et sont représentés par des sprites de militaire. Tout comme le joueur, il peur sauter, marcher et courir.
    - `move_enemy` : Agit comme un "setter" de vitesse pour les ennemis et permet le déplacement.

* Decor : Le décor représente comme son nom l'indique, le décor du jeu (plus précisément celui du niveau en cours). Il n'est inscrit qu'au système de dessin, car sa seule fonction est d'être affiché à l'arrière-plan. Il ne possède pas de fonction unique à elle.

#### Systèmes
Les systèmes représentent des parties importantes du jeu qui s'appliquent à tout moment sur les entités qui y sont inscrites. La boucle principale du jeu présente dans `game.ml` va appeler les fonctions de mise a jour (`update`) des systèmes 60 fois par seconde afin d'agir sur les entités et leurs composants et d'assurer une expérience de jeu continue et sans accroc.

* Collision : Gère et résoud les collisions entre différentes entités.
    - `iter_pairs` : Présent depuis le TP02. Itère sur les paires d'entités présentes dans la séquence d'inscrits, et empèche de vérifier plusieurs fois la même paire.
    - `update` : Appelée depuis la boucle principale, cette fonction s'inspire du TP03 et se sert de la fonction précédente pour détecter les collisions entre entités.
    Elle va construire le rectangle résultat de la différence de Minkowski entre les `box` des deux entités. Si cette dernière contient l'origine, alors il y a collision. Dans ce cas, on détermine de quel côté la première entité à percuté la 2eme, c'est le vecteur de pénétration (Dans le cas où une entité capable de sauter touche quelque chose en dessous de lui, alors il peut de nouveau sauter, on va mettre son composant `is_airborne` à false). On va ensuite replacer les entités vers l'extérieur, et en fonction de leur élasticité ainsi que leur masse, ils seront repousés différemment.
    - `update` : La seconde fonction se contente d'appliquer la première trois fois, pour plus d'efficacité dans la séparation des entités.

* Draw : Dessine les entités inscrites à l'écran.
    - `display_background` : Inspirée des premiers TP, 

## Construction du jeu 

Il suffit de faire `dune build` à la racine. La cible construite par défaut est `prog/game_js.bc.js` qui est incluse dans le fichier HTML `index.html`. Pour construire le programme natif SDL, il faut exécuter la commande `dune build @sdl`.

Pour effacer les fichiers générés, utiliser la commande `dune clean`.

##  Dépendences
Le projet de base requiert `ocaml`, `js_of_ocaml`, `js_of_ocaml-ppx`, `dune`. La production de code natif (testé uniquement sous Linux pour l'instant) requiert `tsdl`, `tsdl-image` et `tsdl-ttf` (ainsi que la bibliothèque SDL native).


## Références
### ECS
https://en.wikipedia.org/wiki/Entity_component_system
https://austinmorlan.com/posts/entity_component_system/
https://tsprojectsblog.wordpress.com/portfolio/entity-component-system/
https://savas.ca/nomad
https://github.com/skypjack/entt
https://ajmmertens.medium.com/building-an-ecs-2-archetypes-and-vectorization-fe21690805f9
https://github.com/SanderMertens/flecs

### Physique/Collision
https://medium.com/@brazmogu/physics-for-game-dev-a-platformer-physics-cheatsheet-f34b09064558
https://www.gamedeveloper.com/design/platformer-controls-how-to-avoid-limpness-and-rigidity-feelings
https://blog.hamaluik.ca/posts/simple-aabb-collision-using-minkowski-difference/
https://www.toptal.com/game/video-game-physics-part-i-an-introduction-to-rigid-body-dynamics
https://www.toptal.com/game/video-game-physics-part-ii-collision-detection-for-solid-objects
https://www.toptal.com/game/video-game-physics-part-iii-constrained-rigid-body-simulation
https://gdcvault.com/play/1021921/Designing-with-Physics-Bend-the