open Map
open Yojson.Safe.Util

type transitions = {
  read : string;
  to_state : string;
  write : string;
  action : string;
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

let transitions_of_json json =
  {
    read = json |> member "read" |> to_string;
    to_state = json |> member "to_state" |> to_string;
    write = json |> member "write" |> to_string;
    action = json |> member "action" |> to_string;
  }

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
  {
    name = json |> member "name" |> to_string;
    alphabet =
      (let chars = json |> member "alphabet" |> to_list |> List.map to_string in
       if List.exists (fun s -> String.length s <> 1) chars then
         failwith "All elements of 'alphabet' must be single characters";
       chars);
    blank = json |> member "blank" |> to_string;
    states = json |> member "states" |> to_list |> List.map to_string;
    initial = json |> member "initial" |> to_string;
    finals = json |> member "finals" |> to_list |> List.map to_string;
    transitions = transitions_tbl;
  }

let print_transition t =
  Printf.printf "    { read = %s; to_state = %s; write = %s; action = %s }\n"
    t.read t.to_state t.write t.action

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
            t.write t.action)
        transitions)
    tm.transitions
