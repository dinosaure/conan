let invalid_arg fmt = Format.kasprintf invalid_arg fmt

type 'a t =
  | True : 'a t
  | Numeric : 'a Integer.t * 'a Comparison.t -> 'a t
  | Float : float Comparison.t -> float t
  | Unicode : Uchar.t Comparison.t -> Uchar.t t
  | String : string Comparison.t -> string t
  | Length : int Comparison.t -> string t
  | Regex : Re.t Comparison.t -> Re.t t

let pf = Format.fprintf

let pp_int ppf = pf ppf "%d"
let pp_float ppf = pf ppf "%f"
let pp_uchar ppf v = pf ppf "U+%04x" (Uchar.to_int v)
let pp_string ppf = pf ppf "%S"

let pp : type a. Format.formatter -> a t -> unit = fun ppf -> function
  | True -> pf ppf "x"
  | Numeric (w, v) -> pf ppf "%a" (Comparison.pp (Integer.pp w)) v
  | Float v -> pf ppf "%a" (Comparison.pp pp_float) v
  | Unicode v -> pf ppf "%a" (Comparison.pp pp_uchar) v
  | String v -> pf ppf "%a" (Comparison.pp pp_string) v
  | Regex v -> pf ppf "%a" (Comparison.pp Re.pp) v
  | Length v -> pf ppf "%a" (Comparison.pp pp_int) v

let always_true = True
let numeric w c = Numeric (w, c)
let float c = Float c
let unicode c = Unicode c
let string c = String c
let length c = Length c
let regex c = Regex c

let process
  : type test v. (test, v) Ty.t -> test t -> v -> v option
  = fun ty test a -> match ty, test with
    | _, True -> Some a
    | Byte _,  Numeric (w, c) -> if Comparison.process w a c then Some a else None
    | Short _, Numeric (w, c) -> if Comparison.process w a c then Some a else None
    | Long _,  Numeric (w, c) -> if Comparison.process w a c then Some a else None
    | Quad _,  Numeric (w, c) -> if Comparison.process w a c then Some a else None
    | Float _,  Float c -> if Comparison.process_float a c then Some a else None
    | Double _, Float c -> if Comparison.process_float a c then Some a else None
    | Unicode _, Unicode _ -> assert false (* TODO *)
    | Search _, String c ->
      if Comparison.process_string a c
      then Some a else None
    | Regex { case_insensitive
            ; _ }, Regex c ->
      let re = Comparison.value c in
      let re = if case_insensitive then Re.no_case re else re in
      let regexp = Re.compile re in
      ( match Array.to_list (Re.Group.all (Re.exec regexp a)) with
        | [] -> None
        | a :: _ -> Some a (* TODO: process the comparison. *) )
    | Double _,      Numeric _ -> .
    | Float _,       Numeric _ -> .
    | Pascal_string, Numeric _ -> .
    | Search _,      Numeric _ -> .
    | Default,       Numeric _ -> .
    | Clear,         Numeric _ -> .
    | _, _ ->
      invalid_arg "%a\t%a not implemented" Ty.pp ty pp test