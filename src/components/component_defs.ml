open Ecs

class id () = (*Class to tell apart entities such as enemies*)
  let r = Component.init 0 in
  object
    method id = r
  end

class last_dt () = (*Time at which the last sprite change occured for the entity.*)
  let r = Component.init 0.0 in
  object
    method last_dt = r
  end

class position () =
  let r = Component.init Vector.zero in
  object
    method position = r
  end

class velocity () =
  let r = Component.init Vector.zero in
  object
    method velocity = r
  end

  class mass () =
  let r = Component.init 0.0 in
  object
    method mass = r
  end

class sum_forces () =
  let r = Component.init Vector.zero in
  object
    method sum_forces = r
  end

class elasticity () = (*Stocke l'élasticité de l'entité. Plus elle est élevée, plus elle rebondit.*)
  let r = Component.init 0.0 in
  object
    method elasticity = r
  end

class box () =
  let r = Component.init Rect.{width = 0; height = 0} in
  object
    method box = r
  end

(*Array of sprite sets (= array of Texture.images) for the entity.
  For example, the player's will have sprite sets for walking, running, jumping...*)
(*The sprites should ALWAYS face right if they have a direction! (So to make them face the right direction if they're moving.)*)
class texture () =
  (*Current value is a placeholder for the entity's load_textures function.*)
  let r = Component.init (Array.init 1 (fun i -> Array.make 1 Texture.black)) in
  object
    method texture = r
  end

(*The sprite set (sub-array of texture component) in which the current sprite for the entity is displayed.*)
class current_sprite_set () =
  let r = Component.init 0 in
  object
    method current_sprite_set = r
  end

(**The sprite currently displayed for the entity.*)
class current_sprite () =
  let r = Component.init 0 in
  object
    method current_sprite = r
  end

type tag = ..
type tag += No_tag

class tagged () =
  let r = Component.init No_tag in
  object
    method tag = r
  end

class resolver () =
  let r = Component.init (fun (_ : Vector.t) (_ : tagged) -> ()) in
  object
    method resolve = r
  end

class is_airborne () = (*Vérifie si l'entité est dans les airs.*)
  let r = Component.init false in
  object
    method is_airborne = r
  end

class action () =
  let r = Component.init (fun () -> ()) in
  object
    method action = r
  end

class hovered_over () =
  let r = Component.init false in
  object
    method hovered_over = r
  end

class clicked () =
  let r = Component.init false in
  object
    method clicked = r
  end

(** Interfaces : ici on liste simplement les types des classes dont on hérite
    si deux classes définissent les mêmes méthodes, celles de la classe écrite
    après sont utilisées (héritage multiple).
*)

class type collidable =
  object
    inherit Entity.t
    inherit position
    inherit box
    inherit mass
    inherit elasticity
    inherit velocity
    inherit tagged
  end

class type drawable =
  object
    inherit Entity.t
    inherit position
    inherit velocity (*Useful in finding out which way the sprite should face.*)
    inherit box
    inherit texture
    inherit current_sprite_set
    inherit current_sprite
    inherit last_dt
    inherit tagged
  end

class type movable =
  object
    inherit Entity.t
    inherit position
    inherit velocity
  end

class type physics =
  object 
    inherit Entity.t
    inherit mass
    inherit sum_forces
    inherit velocity
  end

(** Entités :
    Ici, dans inherit, on appelle les constructeurs pour qu'ils initialisent
    leur partie de l'objet, d'où la présence de l'argument ()
*)
class player name =
  object
    inherit Entity.t ~name ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
    inherit is_airborne ()
  end

type tag += Player of player

class wall () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
  end

type tag += Wall

class enemy () =
  object
    inherit Entity.t ()
    inherit id ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
  end

type tag += Enemy of enemy (**)


class block () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
  end

class level () =
  object
    inherit Entity.t ()
    inherit tagged ()
    inherit id ()
    inherit position ()
    inherit box ()
  end

class plan () =
  object
    inherit Entity.t ()
    inherit tagged ()
    inherit id ()
    inherit position ()
    inherit box ()
    (* inherit tiles () *)
  end

class tile () =
  object
    inherit Entity.t ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit tagged ()
  end

class touchabletile () =
  object
    inherit tile ()
    inherit mass ()
    inherit elasticity ()
  end

class button () =
  object
    inherit Entity.t ()
    inherit id ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit texture ()
    inherit current_sprite_set ()
    inherit current_sprite ()
    inherit last_dt ()
    inherit action ()
    inherit hovered_over ()
    inherit clicked ()
    inherit tagged ()
  end

type tag += Button of button
