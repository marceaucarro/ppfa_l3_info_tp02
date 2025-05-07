(**************************************General********************************)
(*The number of frames before the next sprite in the loop is played.*)
let fps = 7. (*The animations will play at 7 fps.*)

(**************************************Window*********************************)
let window_width = 800
let window_height = 600
let logical_width = 800
let logical_height = 600

(**************************************Player*********************************)
let player_width = 60
let player_height = 100

let player_mass = 80.
let player_elasticity = 0.2

(*List of the files containing the player's sprite sets.*)
let player_sprites = ["player_idle.txt"; "player_walk.txt"; "player_run.txt"; "player_jump_still.txt"]

(*Player's movement constants.*)
let player_v_left = Vector.{ x = -0.5; y = 0.0 }
let player_v_right = Vector.{ x = 0.5; y = 0.0 }
let player_v_jump = Vector.{ x = 0.0; y = -1.4 }

(**************************************Enemy**********************************)
let nb_enemy = 1
let enemy_sprites = ["enemy_textures/enemy_idle.txt" ; "enemy_textures/enemy_walk.txt" ; "enemy_textures/enemy_run.txt" ; "enemy_textures/enemy_jump_still.txt"]

(**************************************Button***********************************)
let buttons_sprites = [(1, "tuto_button.txt"); (2, "quit_button.txt")]

(**************************************Tile***********************************)
let tile_width = 64
let tile_height = 64

let tiles_sprites = "tiles/tiles.txt"

(**************************************Level***********************************)
let nb_levels = 2 
let def_levels = [(0, "level_0.txt") ; (1, "level_1.txt")]

(**************************************Overlay***********************************)
let nb_overlays = 1
let overlays_sprites_filenames = ["menu.png"]

(**************************************Font***********************************)
let font_name = if Gfx.backend = "js" then "monospace" else "resources/images/monospace.ttf"
let font_color = Gfx.color 0 0 0 255
