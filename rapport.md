Quentin WATTELLE, Marceau CARRO

# Rapport de Projet de PFA : Jeu de plateforme "At What Cost"

## Introduction
Pour ce projet, il nous a été demandé de programmer un jeu en OCaml en se servant des bibliothèques GFX et ECS, tout en implémentant des aspects classiques des jeux vidéos tel que les collisions et une physique réaliste.
Nous nous sommes alors mis d'accord sur la réalisation d'un jeu de plateforme dans un univers d'agent secret à deux joueurs : At What Cost.

## Description des éléments du projet

Nous allons à présent expliquer ce que nous avons implanté, en séparant par aspects l'architecture Entité-Composant-Système.
Chaque aspect sera détaillé dans sa propre partie.

#### Composants :
Les composants représentent les différents outils qui vont permettre aux entités d'être correctement représentées auprès des systèmes (dessin, collisions, forces...).
Voici la liste de ceux-ci:

* `id` : Identifiant pour chaque objet de la même entité, permet de différentier chaque objet d'une même entité.
* `id_level` : Identifiant unique pour chaque niveau, permet de placer une entité dans un level particulier. Ainsi, chaque entité peut prendre place dans un niveau et un seul.
* `tagged` : Agit comme une étiquette, permet de reconnaître une entité lors d'un pattern-matching.
* `position` : Contient le vecteur de position de l'entité.
* `velocity` : Contient le vecteur vitesse de l'entité.
* `mass` : Contient la masse de l'entité, qui influe sur les collisions entre les entités.
* `elasticity` : Inspiré du TP03, contient l'élasticité de l'entité : c'est la force avec laquelle il va rebondir lorsqu'il entrera en collision avec d'autres entités.
* `sum_forces` : Représente la somme des forces qui s'exercent sur l'entité.
* `box` : Contient les dimensions de l'entité, pour les collisions ou encore le dessin.
* `texture` : Contient un tableau de tableau de Textures. Dans le cas des entités comme le joueur ou les ennemis, chaque sous-array contiendra l'ensemble des images correspondant à une animation de l'entité (marche, course...).
* `current_sprite_set` : Indique l'indice du sous-array dans lequel se trouve l'image actuellement utilisée par le système de dessin. Par exemple, pour le joueur et les ennemis, il indique quelle animation est actuellement affichée (par exemple, le saut).
* `current_sprite` : Indique l'indice de l'image actuellement affichée au sein du sous-array d'indice `current_sprite_set` du composant `texture`. En reprenant l'exemple précédent, si nous sommes en train de courir, on sera donc en train d'afficher une des images du sous-array correspondant.
* `last_dt` : Inspiré du TP01, contient le temps écoulé entre le début de l'exécution du programme et la dernière fois que l'image actuelle affichée pour l'entité a été changée. Cela nous permet de contrôler la vitesse à laquelle les animations jouent.
* `is_airborne` : Pour les entités capable de sauter, indique si ces derniers sont en l'air. Si c'est le cas, leur action de saut est désactivée jusqu'à ce qu'ils retouchent le sol.
* `action` : Pour les entités ayant une action spécifique suite à une intéraction. Cette action se traduit par une fonction unit -> unit. Pour les boutons, une suite d'actions précisent permet de lancer une fonction. Par exemple, changer de niveau ou quitter le jeu.
* `hovered_over` : Pour les entités ayant une réaction spécifique au fait d'être survolées par la souris. Pour les boutons, cela se caractérise par le fait de changer de texture.
* `cliked` : Pour les entité ayant une réaction spécifique au fait d'être cliquées par la souris. Pour les boutons, cela se caractérise par le fait de changer de texture.


#### Entités :
Continuons avec les entités, les différents éléments qui vont se retrouver à intéragir avec le joueur via les différents systèmes.
Ils héritent de nombreux composants, pour mieux gérer leurs interactions avec les systèmes auxquels ils sont inscrits. 

Nous allons surtout nous concentrer sur les fonctions du fichier entité correspondant.

Chaque entité possède en commun :
* Une fonction de création qui va être utilisé par `game.ml` pour initialiser les entités.
* Un ou des "getters", qui vont récupérer ces entités créées via l'objet `Global`.
* Une fonction de chargement de lot d'images (`load_spriteset` pour Player et Enemy) :
Pour Player et Enemy, elle charge un sprite set (un ensemble d'images correspondant à une animation) dans le sous-array de texture indiqué.
Nous nous sommes inspirés du TP01 en allant d'abord chercher les noms d'images nécessaires à l'animation dans un fichier, puis en allant chercher les imageselles-mêmes à partir de ces noms. Après avoir découpé la chaîne de caractère du fichier en une liste de noms d'images. Enfin, après s'être assuré que toutes les images soient prêtes, on les met dans un array qui va remplacer le sous-array initialement "vide" (il ne contient qu'une couleur unie).
* `load_textures` : Répète le travail pour toutes les entités de ce type présentes dans `Global`.
Par la suite, la fonction update du système Draw pourra afficher les images correctement.

Faisons à présent l'inventaire des entités et de leurs fonctions uniques :

* Screen : La fenêtre est une entité qui décrit la position globale de la "caméra". Cette entité permet dans le système draw d'afficher que les entités qui sont dans la fenêtre. Ainsi, seulement la "caméra" bouge, le reste ne bouge pas. Le déplacement de la "caméra" se fait grâce au déplacement du joueur.

* Player : Le joueur est le personnage principal de notre jeu, ici représenté par un sprite d'agent secret. Il est capable de plusieurs actions basiques, soit la marche, la course et le saut. Voici ses fonctions "uniques":
    - `stop_players` : Arrête l'entité Player en mettant le vecteur vitesse à 0.
    - `move_player` : Agit comme un "setter" de vitesse pour le joueur et permet le déplacement, on s'en sert dans `input.ml` pour déplacer le joueur quand on appuie sur la touche correspondante.

* Enemy : Les ennemis sont la menace principale du jeu, et sont représentés par des sprites de militaire. Tout comme le joueur, ils peuvent sauter, marcher et courir.
    - `move_enemy` : Agit comme un "setter" de vitesse pour les ennemis et permet le déplacement.

* Button : Les boutons permettent, suite au fait d'être cliqués, de lancer une fonction unit -> unit spécifique. Par exemple, le bouton Play ative une fonction qui change le niveau courant de 0 à 1. Les boutons changent de texture lorsqu'ils sont survolés ou cliqués par la souris.

* Tile : Les tuiles ou "tiles" sont des carrés de 64 par 64 pixels. Chaque niveau est séparé par 3 plans (le fond distant, le fond plus proche du joueur et le plan qui sont devant le joueur). Chaque plan contient des tiles organisées en grille. Chaque tile à une position x et y et une texture, elles sont juste inscrit dans le système Draw. 

* Wall : Les murs sont des objets invisibles (non-inscrit dans le système draw) qui permettent de délimiter un niveau, de rendre une tuile infranchissable. Par exemple, un mur aura exactement la même position qu'une tuile que l'on veut être infranchissable.

* Overlay : Les revêtements sont juste des images qui n'intéragissent avec rien et qui sont dessinés.


#### Systèmes
Les systèmes représentent des parties importantes du jeu qui s'appliquent à tout moment sur les entités qui y sont inscrites. La boucle principale du jeu présente dans `game.ml` va appeler les fonctions de mise a jour (`update`) des systèmes 60 fois par seconde afin d'agir sur les entités et leurs composants et d'assurer une expérience de jeu continue et sans accroc.

* Collision : Gère et résoud les collisions entre différentes entités du niveau courant.
    - `iter_pairs` : Présent depuis le TP02. Itère sur les paires d'entités présentes dans la séquence d'inscrits, et empèche de vérifier plusieurs fois la même paire.
    - `update` : Appelée depuis la boucle principale, cette fonction s'inspire du TP03 et se sert de la fonction précédente pour détecter les collisions entre entités.
    Elle va construire le rectangle résultat de la différence de Minkowski entre les `box` des deux entités. Si cette dernière contient l'origine, alors il y a collision. Dans ce cas, on détermine de quel côté la première entité a percuté la 2eme, c'est le vecteur de pénétration (Dans le cas où une entité capable de sauter touche quelque chose en dessous de lui, alors il peut de nouveau sauter, on va mettre son composant `is_airborne` à false). On va ensuite replacer les entités vers l'extérieur, et en fonction de leur élasticité ainsi que leur masse, ils seront repousés différemment.

* Draw : Dessine les entités du niveau courant inscrites à l'écran.
    - `update_button` : Affiche les boutons du niveau courant. Mets à jour la texture utilisée selon si le bouton est survolé ou cliqué.
    - `display_tiles` : Affiche les tuiles du niveau courant. On commence par vérifier si le composant texture a bien reçu les images (En effet, nous n'avons pas pu coder les fonctions de chargement de ressources de telle façon que la fonction `update` de `game.ml` soit la fonction de continuation de `load_ressources`. Par conséquent, update commence à s'éxécuter avant que textures soit mis à jour. Il est donc nécéssaire de vérifier pour s'assurer de ne pas faire un accès en dehors des bornes).
    Si tout est chargé, on itère sur le plan donnée (la liste des tuiles du plan) et on regarde si une tuile est visible dans la caméra. Pour faire cela, on fait des calculs sur les positions globales pour obtenir les positions locals, dans la caméra. Si une tuiles n'est pas visible, on ne l'affiche pas. Si il est visible, on affiche la tuile selon la position globale de la caméra. 
    - `display_overlays` : Affiche les revêtements (les images) sur l'écran. Ici, on ne prend pas en compte la caméra.
    - `update_human` : Affiche les entités humaines (`Player` et `Enemy`) en fonction de la situation dans laquelle elles se trouvent.
    On verifie d'abord que les images soient bien dans le tableau. Ensuite, on vérifie dans quel sens le vecteur de vitesse se trouve, pour savoir dans quel sens doit regarder le personnage. Ensuite, s'il est dans les airs, on se place dans le sous-array de texture dans lequel se trouve l'animation de saut. Sinon, en fonction de la vitesse, on choisit soit l'animation "IDLE" (on reste debout sans rien faire), la marche ou la course.
    Ensuite, on affiche et enfin, comme les animations se doivent de paraître vivantes, nous nous sommes inspirés du TP01 et sa variable `last_dt` pour changer l'image de l'animation à intervalles constants. Dans notre cas, la mise à jour se fait sept fois par secondes, donc la boucle de l'animation se fait à 7 fps.
    - `update` : La fonction update commence par afficher le fond d'écran, puis itère sur le reste des entités pour les afficher. Ensuite, il affiche les tuiles qui doivent être afficher devant tous les autres éléments. Enfin, il affiches les revêtements (images) qui n'intéragissent avec rien.

* Forces : Prend en compte les différentes forces qui s'appliquent sur les entités du niveau courant.
    - `update` : Fonction inspirée d'un des TP puis corrigée. On itère sur les entités inscrites et on leur applique l'ensemble des forces présentes dans la composante `sum_forces`, additionné au poids du l'entité. On se sert ensuite de la formule $$a =  \frac{\sum F}{m}$$ pour trouver l'accélération, puis la vitesse, et on ajoute le frottement avant de mettre à jour la composante de vitesse.

* Move : Met a jour la position d'une entité du niveau courant.
    - `update` : Prend la position et la vitesse de d'une entité, et s'en sert pour calculer la position à la frame qui suit.


## Initialisation du jeu

Nous allons prendre le temps de décrire les nouvelles fonctions de `game.ml`. Les autres ne sont pas présentes ici car elles sont identiques au début du projet.

* `game.ml` : Contient le nécéssaire pour démarrer le jeu.
    - `load_ressources` : Appelle les fonctions load\_textures des différentes entités.
    - `update` : Prépare la prochaine frame du jeu en prenant en compte les input (pour le mouvement, les sauts...), puis met à jour tous les systèmes : les fonctions `update` de Force, Move, Collision et Draw sont appelées.
    - `run` : Initialise les différentes entités du jeu et les ajoute à `Global`, puis charge les textures via `load_ressources` avant de mettre en place la boucle principale qui appelle `update` 60 fois par seconde.


## Organisation des données

Maintenant, nous allons décrire comment sont organisés les données dans le fichier `/resources`.

* `/resources/files/` : Répertoire contenant, pour chaque entité, l'ensemble des chemins vers les données qui lui sont associés. Cela peut être des chemins vers des images ou des données d'initialisation. Il y a quelques exceptions où les données sont directement inscrites sans renvoyer à un autre fichier.

* `/resources/images/` : Répertoire contenant, pour chaque entité, l'ensemble des images qui lui sont associées. Il peut y avoir pour certains entités des sous-répertoires selon les différentes animations ou identifiants spécifiques. 

* `/resources/levels` : Répertoire contenant, pour chaque niveau, l'ensemble des données décrivant le niveau et l'emplacement des tuiles. Pour un niveau n, il y a 4 fichiers presque tous agancés de la même manière. Une ligne représente une ligne de tuile, chaque nombre dans une ligne représente un identifiant correspondant à une texture :
    - level\_n\_0.txt : Représente le plan correspondant au fond qui est loin du personnage.
    - level\_n\_1.txt : Représente le plan correspondant au fond qui est proche du personnage.
    - level\_n\_2.txt : Représente le plan correspondant à ce qui est devant le personnage.
    - level\_n\_walls.txt : Représente les murs invisibles dans un niveau. La signification des nombres est différentes des trois autres : si c'est 0 alors il n'y a pas de murs invisibles à cette tuile, sinon il y en a un.


## Constantes

Pour terminer, nous allons décrire l'ensemble des constantes qui ont été ajoutées à `cst.ml`:

* General
    - `fps` : Indique combien de fois par secondes les "sprites" des personnages doivent changer dans Draw.

* Window
    - `window_width` : Largeur de la fenêtre.
    - `window_height` : Hauteur de la fenêtre.
    - `logical_width` : Largeur de la fenêtre logique.
    - `logical_height` : Hauteur de la fenêtre logique.

* Player
    - `player_width` : Largeur du joueur.
    - `player_height` : Hauteur du joueur.
    - `player_mass` : La masse du joueur.
    - `player_elasticity` : L'élasticité du joueur.
    - `player_sprites` : Contient le liste des fichiers à visiter pour obtenir l'ensemble des animations pour le joueur. Chaque élément correspond à une animation comme la marche ou la course.
    - `player_v_left` : Indique la vitesse de mouvement maximale lorsque le joueur de déplace vers la gauche.
    - `player_v_right` : Indique la vitesse de mouvement maximale lorsque le joueur de déplace vers la droite.
    - `player_v_jump` : Indique l'intensité avec laquelle le joueur va sauter.

* Enemy
    - `nb_enemy` : Nombre d'ennemis présent dans l'ensemble du jeu
    - `enemy_sprites` : Contient la liste des fichiers à visiter pour obtenir l'ensemble des animations pour les ennemis. Chaque élément correspond à une animation comme la marche ou la course.

* Button
    - `buttons_sprites` : Contient la liste des fichiers à visiter pour obtenir l'ensemble des images pour les boutons. Chaque élément est un couple avec un id unique et le chemin vers un fichier contenant les textures nécessaires.

* Tile
    - `tile_width` : Largeur d'une tuile
    - `tile_height` : Hauteur d'une tuile
    - `tiles_sprites` : Chemin du fichier contenant tous les fichiers correspondant aux textures des tuiles.

* Level
    - `nb_levels` : Nombre de levels dans l'ensemble du jeu
    - `def_levels` : Contient la liste des fichiers à visiter pour obtenir l'ensemble des informations pour les niveaux. Chaque élément est un couple avec un id unique et le chemin vers un fichier contenant les textures nécessaire.

* Overlay
    - `nb_overlays` : Nombre de revêtements (images) dans l'ensemble du jeu
    - `overlays_sprites_filenames` : Contient la liste des fichiers à visiter pour obtenir l'ensemble des iamges pour les revêtements.


#### Sources :
Voici ci-après les sources des différentes ressources utilisées dans ce projet:
* Player : https://chasersgaming.itch.io/adventure-asset-character-agent-sms.
* Enemy : https://chasersgaming.itch.io/brawler-asset-character-soldier-sms.
* Decor : https://chasersgaming.itch.io/brawler-asset-tile-set-military-base-sms.
