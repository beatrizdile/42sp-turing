open Map
open Yojson.Safe.Util
open Types
open Validation

let transitions_of_json json =
  {
    read = json |> member "read" |> to_string;
    to_state = json |> member "to_state" |> to_string;
    write = json |> member "write" |> to_string;
    action =
      (match json |> member "action" |> to_string with
      | "LEFT" -> LEFT
      | "RIGHT" -> RIGHT
      | invalid_action ->
          failwith (Printf.sprintf "Invalid action type '%s'" invalid_action));
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
  let chars = json |> member "alphabet" |> to_list |> List.map to_string in
  let blank = json |> member "blank" |> to_string in
  let machine =
    {
      name = json |> member "name" |> to_string;
      alphabet = chars;
      blank;
      states = json |> member "states" |> to_list |> List.map to_string;
      initial = json |> member "initial" |> to_string;
      finals = json |> member "finals" |> to_list |> List.map to_string;
      transitions = transitions_tbl;
    }
  in
  verify_machine machine;
  machine
