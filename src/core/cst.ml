(**************************************General********************************)
(*The number of frames before the next sprite in the loop is played.*)
let fps = 7. (*The animations will play at 7 fps.*)

(**************************************Window*********************************)
let window_width = 800
let window_height = 600
let logical_width = 800
let logical_height = 600

(**************************************Level***********************************)
let decor_tilesets = ["level_0.txt"]

(*Decor tiles to display from left to right.
Each tupple has the index to the tile to take from the decor's texture component (in this case, in sub-array 0),
as well as the width of the tile, the height, and whether if should be flipped vertically.*)
let lvl_0_pattern =
  [(0, (210*logical_height/250), (250*logical_height/250), false);
  (1, (210*logical_height/250), (250*logical_height/250), false);
  (2, (210*logical_height/250), (250*logical_height/250), false);
  (3, (115*logical_height/250), (250*logical_height/250), false)]

(*List of all levels' display patterns.*)
let lvl_patterns = [|lvl_0_pattern|]

(**************************************Walls***********************************)
let wall_thickness = 32

let hwall_width = window_width
let hwall_height = wall_thickness
let hwall1_x = 0
let hwall1_y = 0
let hwall2_x = 0
let hwall2_y = window_height -  wall_thickness
let hwall_color = Texture.green

let vwall_width = wall_thickness
let vwall_height = window_height - 2 * wall_thickness
let vwall1_x = 0
let vwall1_y = wall_thickness
let vwall2_x = window_width - wall_thickness
let vwall2_y = vwall1_y
let vwall_color = Texture.yellow

(**************************************Player*********************************)
let player_width = 60
let player_height = 100

let player_mass = 80.
let player_elasticity = 0.2

let player1_x = window_width/4 + wall_thickness
let player1_y = window_height - wall_thickness - player_height

let player2_x = window_width - player1_x - player_width
let player2_y = player1_y
let player_color = Texture.blue

(*List of the files containing the player's sprite sets.*)
let player_sprites = ["player_idle.txt"; "player_walk.txt"; "player_run.txt"; "player_jump_still.txt"]

(*Player's movement constants.*)
let player_v_left = Vector.{ x = -0.5; y = 0.0 }
let player_v_right = Vector.{ x = 0.5; y = 0.0 }
let player_v_jump = Vector.{ x = 0.0; y = -1.4 }

(**************************************Enemy**********************************)

let enemy_color = Texture.red

let enemy_width = 60
let enemy_height = 100

let enemy_mass = 80.
let enemy_elasticity = 0.2

let enemy_x = window_width*3/4 - wall_thickness   (*Pourrait devenir un tableau éventuellement*)
let enemy_y = window_height - wall_thickness - player_height

let enemy_sprites = ["enemy_idle.txt"; "enemy_walk.txt"; "enemy_run.txt"; "enemy_jump_still.txt"]

(**************************************Font***********************************)
let font_name = if Gfx.backend = "js" then "monospace" else "resources/images/monospace.ttf"
let font_color = Gfx.color 0 0 0 255
