open Map
open Yojson.Safe.Util
open Types
open Validation

let transition_from_json transition =
  {
    read = transition |> member "read" |> to_string;
    to_state = transition |> member "to_state" |> to_string;
    write = transition |> member "write" |> to_string;
    action =
      (match transition |> member "action" |> to_string with
      | "LEFT" -> LEFT
      | "RIGHT" -> RIGHT
      | invalid_action ->
          failwith (Printf.sprintf "Invalid action type '%s'" invalid_action));
  }

let transitions_from_json json =
  let transitions_json = json |> member "transitions" |> to_assoc in
  let transitions_tbl = Hashtbl.create (List.length transitions_json) in
  List.iter
    (fun (state, trans_list_json) ->
      let trans_list =
        trans_list_json |> to_list |> List.map transition_from_json
      in
      Hashtbl.add transitions_tbl state trans_list)
    transitions_json;
  transitions_tbl

let turing_machine_from_json json =
  {
    name = json |> member "name" |> to_string;
    alphabet = json |> member "alphabet" |> to_list |> List.map to_string;
    blank = json |> member "blank" |> to_string;
    states = json |> member "states" |> to_list |> List.map to_string;
    initial = json |> member "initial" |> to_string;
    finals = json |> member "finals" |> to_list |> List.map to_string;
    transitions = json |> transitions_from_json;
  }
