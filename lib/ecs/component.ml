let init v =
  object
    val mutable r = v
    method get = r
    method set w = r <- w
  end