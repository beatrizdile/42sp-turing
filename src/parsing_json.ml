open Map
open Yojson.Safe.Util

type action_type = RIGHT | LEFT

type transitions = {
  read : string;
  to_state : string;
  write : string;
  action : action_type;
}

type turing_machine = {
  name : string;
  alphabet : string list;
  blank : string;
  states : string list;
  initial : string;
  finals : string list;
  transitions : (string, transitions list) Hashtbl.t;
}

let action_to_sting = function
  | RIGHT -> "RIGHT"
  | LEFT -> "LEFT"

let check_single_char str field =
  if String.length str <> 1 then
    failwith (Printf.sprintf "All elements of '%s' must be single characters" field)

let check_single_char_list lst field =
  List.iter (fun s -> check_single_char s field) lst

let transitions_of_json json =
  let read = json |> member "read" |> to_string in
  check_single_char read "read";

  let write = json |> member "write" |> to_string in
  check_single_char write "write";
  {
    read = read;
    to_state = json |> member "to_state" |> to_string;
    write = write;
    action = match json |> member "action" |> to_string with
    | "LEFT" -> LEFT
    | "RIGHT" -> RIGHT
    | invalid_action -> failwith (Printf.sprintf "Invalid action type '%s'" invalid_action);
  }

(* Deve verificar se
- Se o to_state dos transitions existe nos states
- Se os states existem em transitions
- Se todos os transitions existem nos states

states - finals = states that MUST exist in transitions:

["scanright", "eraseone", "subone", "skip", "HALT"] - ["HALT"]
= ["scanright", "eraseone", "subone", "skip"] -> must be specified in transitions
*)

let check_if_in_alphabet str alphabet =
  try
    List.find (fun letter -> letter = str) alphabet
  with
  | e -> failwith (Printf.sprintf "The elemet '%s' not in alphabet" str)

let verify_machine machine =
  ignore (check_single_char_list machine.alphabet "alphabet");
  ignore (check_single_char machine.blank "blank");
  ignore (check_if_in_alphabet machine.blank machine.alphabet);

  Hashtbl.iter (fun _state transitions_list ->
    List.iter (fun t -> 
      ignore (check_if_in_alphabet t.read machine.alphabet);
      ignore (check_if_in_alphabet t.write machine.alphabet);
    ) transitions_list
  ) machine.transitions

let turing_machine_from_json json =
  let transitions_tbl = Hashtbl.create 10 in
  let transitions_json = json |> member "transitions" |> to_assoc in
  List.iter
    (fun (state, trans_list_json) ->
      let trans_list =
        trans_list_json |> to_list |> List.map transitions_of_json
      in
      Hashtbl.add transitions_tbl state trans_list)
    transitions_json;
  let chars = json |> member "alphabet" |> to_list |> List.map to_string in
  let blank = json |> member "blank" |> to_string in
  let machine = {
    name = json |> member "name" |> to_string;
    alphabet = chars;
    blank = blank;
    states = json |> member "states" |> to_list |> List.map to_string;
    initial = json |> member "initial" |> to_string;
    finals = json |> member "finals" |> to_list |> List.map to_string;
    transitions = transitions_tbl;
  } in
  verify_machine machine;
  machine

let print_transition t =
  Printf.printf "    { read = %s; to_state = %s; write = %s; action = %s }\n"
    t.read t.to_state t.write (action_to_sting t.action)

let print_turing_machine tm =
  let border = String.make 80 '*' in
  let center_text text =
    let len = String.length text in
    let padding = (76 - len) / 2 in
    Printf.sprintf "*%s%s%s*" (String.make padding ' ') text
      (String.make (76 - len - padding) ' ')
  in
  Printf.printf "%s\n" border;
  Printf.printf "%s\n" (center_text "");
  Printf.printf "%s\n" (center_text tm.name);
  Printf.printf "%s\n" (center_text "");
  Printf.printf "%s\n" border;
  Printf.printf "Alphabet: [ %s ]\n" (String.concat ", " tm.alphabet);
  Printf.printf "States  : [ %s ]\n" (String.concat ", " tm.states);
  Printf.printf "Initial : %s\n" tm.initial;
  Printf.printf "Finals  : [ %s ]\n" (String.concat ", " tm.finals);
  Hashtbl.iter
    (fun state transitions ->
      List.iter
        (fun t ->
          Printf.printf "(%s, %s) -> (%s, %s, %s)\n" state t.read t.to_state
            t.write (action_to_sting t.action))
        transitions)
    tm.transitions
