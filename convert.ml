open ApiTypes

let grade_of_string s =
  let subgrade = match s.[1] with
    | '1' -> 1
    | '2' -> 2
    | '3' -> 3
    | '4' -> 4
    | '5' -> 5
    | _ -> failwith "Invalid grade" in
  match s.[0] with
  | 'A' -> A (subgrade)
  | 'B' -> B (subgrade)
  | 'C' -> C (subgrade)
  | 'D' -> D (subgrade)
  | 'E' -> E (subgrade)
  | 'F' -> F (subgrade)
  | 'G' -> G (subgrade)
  | _ -> failwith "Invalid grade"

let string_of_grade = function
  | A i -> "A" ^ string_of_int i
  | B i -> "B" ^ string_of_int i
  | C i -> "C" ^ string_of_int i
  | D i -> "D" ^ string_of_int i
  | E i -> "E" ^ string_of_int i
  | F i -> "F" ^ string_of_int i
  | G i -> "G" ^ string_of_int i

let credit_trend_of_string = function
  | "UP" -> Up
  | "DOWN" -> Down
  | "FLAT" -> Flat
  | _ -> failwith "Invalid credit trend"
