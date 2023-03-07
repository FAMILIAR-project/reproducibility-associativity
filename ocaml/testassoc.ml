open Random
open Printf

type equality_check =
  | Associativity
  | Mult_inv
  | Mult_inv_pi

let equality_test (equality_check : equality_check) x y z : bool =
  match equality_check with
  | Associativity ->
      x +. (y +. z) = (x +. y) +. z
  | Mult_inv ->
      (x *. z) /. (y *. z) = x /. y
  | Mult_inv_pi ->
      (x *. z *. Float.pi) /. (y *. z *. Float.pi) = x /. y

let proportion number seed_val equality_check : float =
  (* according to ChatGPT: If seed_val is None, 
     then Random.init will use the current time as the seed, which will result in a different sequence of random numbers every time the program is run. 
     This may be desirable in some cases (e.g., when running tests that should not depend on a specific random seed), but not in others (e.g., when trying to reproduce a specific sequence of random numbers). 
     It seems wrong according to the doc here:
     https://v2.ocaml.org/api/Random.html *)  
  Random.init seed_val; 
  let ok = ref 0 in
  for i = 0 to number - 1 do
    let x = Random.float 1.0 in
    let y = Random.float 1.0 in
    let z = Random.float 1.0 in
    if equality_test equality_check x y z then
      incr ok
  done;
  float_of_int !ok *. 100.0 /. float_of_int number

let () =
  let open Arg in
  let seed = ref None in
  let number = ref 10000 in
  let equality_check = ref None in
  let options =
    [ ("--seed", Int (fun x -> seed := Some x), "Seed value.")
    ; ("--number", Int (fun x -> number := x), "Number of tests.")
    ; ("--equality-check", Symbol (List.map (fun ec ->
        match ec with
        | Associativity -> "associativity"
        | Mult_inv -> "mult-inverse"
        | Mult_inv_pi -> "mult-inverse-pi") [Associativity; Mult_inv; Mult_inv_pi],
      (fun x -> match x with
        | "associativity" -> equality_check := Some Associativity
        | "mult-inverse" -> equality_check := Some Mult_inv
        | "mult-inverse-pi" -> equality_check := Some Mult_inv_pi
        | _ -> ())), "Type of equality check.")
    ]
  in
  let usage_msg = "Equality test with seed." in
  let () =
    parse options (fun _ -> ()) usage_msg;
    match !seed, !equality_check with
    | Some seed_val, Some ec ->
        printf "%.2f%%\n" (proportion !number seed_val ec)
    | _, _ ->
        eprintf "Missing required arguments: --seed, --equality-check\n";
        exit 1
  in
  ()
