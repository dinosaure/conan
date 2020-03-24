type 'a t = private
  | True : 'a t
  | Numeric : 'a Integer.t * 'a Comparison.t -> 'a t
  | Float : float Comparison.t -> float t
  | Unicode : Uchar.t Comparison.t -> Uchar.t t
  | String : string Comparison.t -> string t
  | Length : int Comparison.t -> string t
  | Regex : Re.t Comparison.t -> Re.t t

val pp : Format.formatter -> 'a t -> unit

val always_true : _ t
val numeric : 'w Integer.t -> 'w Comparison.t -> 'w t
val float : float Comparison.t -> float t
val unicode : Uchar.t Comparison.t -> Uchar.t t
val string : string Comparison.t -> string t
val length : int Comparison.t -> string t
val regex : Re.t Comparison.t -> Re.t t

val process : ('test, 'v) Ty.t -> 'test t -> 'v -> 'v option