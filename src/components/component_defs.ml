open Ecs

class id () = (*Class to tell apart entities such as enemies*)
  let r = Component.init 0 in
  object
    method id = r
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

class texture () =
  let r = Component.init (Texture.Color (Gfx.color 0 0 0 255)) in
  object
    method texture = r
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
    inherit box
    inherit texture
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
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
  end

type tag += Wall

class enemy =
  object
    inherit Entity.t ()
    inherit id ()
    inherit position ()
    inherit velocity ()
    inherit box ()
    inherit tagged ()
    inherit texture ()
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
    inherit mass ()
    inherit elasticity ()
    inherit sum_forces ()
  end
