Quentin Wattelle, Marceau CARRO
# Rapport de Projet de PFA : Jeu de plateforme "At What Cost"

## Introduction
Pour ce projet, il nous était demandé de programmer un jeu en OCaml en se servant des bibliothèques Gfx et ECS, et en implémentant des aspects classiques des jeux vidéos tel que les collisions.
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
    - `display_background` : Inspirée des premiers TP, cette fonction se sert de l'entité de type Decor pour afficher l'arrière-plan.
    On commence par vérifier si le composant texture a bien reçu les images (En effet, nous n'avons pas pu coder les fonctions de chargement de ressources de telle façon que la fonction `update` de `game.ml` soit la fonction de continuation de `load_ressources`. Par conséquent, update commence à s'éxécuter avant que textures soit mis à jour. Il est donc nécéssaire de vérifier pour s'assurer de ne pas faire un accès en dehors des bornes). Si c'est le cas, on commence à afficher : on itère sur la constante lvl_pattern (détaillée dans la section Constantes) qui est un array de listes de quadruplets : chaque sous-liste représente un niveau, et chaque quadruplet les infos sur quelle image afficher et comment.
    On affiche en se servant du décor comme d'un tampon : On affiche la première image au point (0,0), puis se déplace sur l'axe x de façon à se retrouver juste à droite de l'image, et on recommence jusqu'à ce qu'on ait tout affiché comme on l'a indiqué via lvl_pattern.
    - `update_human` : Affiche les entités humaines (`Player` et `Enemy`) en fonction de la situation dans laquelle elles se trouvent.
    On verifie d'abord que les images soient bien dans le tableau. Ensuite, on vérifie dans quel sens le vecteur de vitesse se trouve, pour savoir dans quel sens doit regarder le personnage. Ensuite, s'il est dans les airs, on se place dans le sous-array de texture dans lequel se trouve l'animation de saut. Sinon, en fonction de la vitesse, on choisit soit l'animation "IDLE" (on reste debout sans rien faire), la marche ou la course.
    Ensuite, on affiche et enfin, comme les animations se doivent de paraître vivantes, nous nous sommes inspirés du TP01 et sa variable `last_dt` pour changer l'image de l'animation à intervalles constants. Dans notre cas, la mise à jour se fait sept fois par secondes, donc la boucle de l'animation se fait à 7 fps.
    - `update` : La fonction update commence par afficher le fond d'écran, puis itère sur le reste des entités pour les afficher. On note que décor est ici ignoré pour ne pas recouvrir le reste de l'image.

* Forces : Prend en compte les différentes forces qui s'appliquent sur les entités.
    - `update` : Fonction inspirée d'un des TP puis corrigée. On itère sur les entités inscrites et on leur applique l'ensemble des forces présentes dans la composante `sum_forces`, additionné au poids du l'entité. On se sert ensuite de la formule $$a =  \frac{\sum F}{m}$$ pour trouver l'acceleration, puis la vitesse, et on ajoute le frottement avant de mettre à jour la composante de vitesse.

* Move : Met a jour la position de l'entité.
    - `update` : Prend la position et la vitesse de l'entité, et s'en sert pour calculer la position à la frame qui suit.

#### Initialisation du jeu

Nous allons prendre le temps de décrire les nouvelles fonctions de `game.ml`. Les autres ne sont pas présentes ici car elles sont identiques au début du projet.

* `game.ml` : Contient le nécéssaire pour démarrer le jeu.
    - `load_ressources` : Appelle les fonctions load_textures des différentes entités.
    - `update` : Prépare la prochaine frame du jeu en prenant en compte les input (pour le mouvement, les sauts...), puis met à jour tous les systèmes : les fonctions `update` de Force, Move, Collision et Draw sont appelées.
    - `run` : Initialise les différentes entités du jeu et les ajoute à `Global`, puis charge les textures via `load_ressources` avant de mettre en place la boucle principale qui appelle `update` 60 fois par seconde.

#### Constantes

Nous allons maintenant décrire l'ensemble des constantes qui ont été ajoutées à `cst.ml`:

* General
    - `fps` : Indique combien de fois par secondes les "sprites" des personnages doivent changer dans Draw.

* Window
    - `logical_width` : Largeur de la fenêtre logique.
    - `logical_height` : Hauteur de la fenêtre logique.

* Level
    - `decor_tilesets` : Contient une liste où chaque entrée d'indice i contient le nom du fichier où on peut trouver le nom des images du niveau n°i.
    - `lvl_0_pattern` : Contient une liste de quadruplets, qui indique comment afficher l'arrière-plan du niveau de gauche à droite. Chaque quadruplet est de la forme (i, w, h, flipped), ou i est l'indice de l'image dans le sous-array 0 du composant texture de Decor, w la largeur qu'il prendra, h la hauteur, et flipped s'il doit être inversé verticalement.
    - `lvl_patterns` : Contient un array des patternes des niveaux du jeu.

* Player
    - `player_mass` : La masse du joueur.
    - `player_elasticity` : L'élasticité du joueur.
    - `player_sprites` : Contient le liste des fichiers à visiter pour obtenir l'ensemble des animations pour le joueur. Chaque élément correspond à une animation comme la marche ou la course.
    - `player_v_left` : Indique la vitesse de mouvement maximale lorsque le joueur de déplace vers la gauche.
    - `player_v_right` : Indique la vitesse de mouvement maximale lorsque le joueur de déplace vers la droite.
    - `player_v_jump` : Indique l'intensité avec laquelle le joueur va sauter.

* Enemy
    - `enemy_color` : La couleur par défaut de l'ennemi.
    - `enemy_width` : La largeur du composant `box` de l'ennemi.
    - `enemy_height` : La hauteur du composant `box` de l'ennemi.
    - `enemy_x` : La position de l'apparition de l'ennemi sur l'axe x.
    - `enemy_y` : La position de l'apparition de l'ennemi sur l'axe y.
    - `enemy_mass` : La masse de l'ennemi.
    - `enemy_elasticity` : L'élasticité de l'ennemi.
    - `enemy_sprites` : Contient le liste des fichiers à visiter pour obtenir l'ensemble des animations pour les ennemis. Chaque élément correspond à une animation comme la marche ou la course.

## Sources :
Voici ci-après les sources des différentes ressources utilisées dans ce projet:
* Player : https://chasersgaming.itch.io/adventure-asset-character-agent-sms.
* Enemy : https://chasersgaming.itch.io/brawler-asset-character-soldier-sms.
* Decor : https://chasersgaming.itch.io/brawler-asset-tile-set-military-base-sms.
