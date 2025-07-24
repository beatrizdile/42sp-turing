open Map
open Yojson.Safe.Util
open Types

let check_single_char str field =
  if String.length str <> 1 then
    failwith
      (Printf.sprintf "All elements of '%s' must be single characters" field)

let check_single_char_list lst field =
  List.iter (fun s -> check_single_char s field) lst

let string_in_list str lst =
  if List.exists (fun s -> s = str) lst == false then
    failwith (Printf.sprintf "Element '%s' not found in list" str)

let equal_lists l1 l2 =
  let sort_lst lst = List.sort compare lst in
  if sort_lst l1 <> sort_lst l2 then failwith "Lists of states are not equal"

let check_if_in_alphabet str alphabet =
  try List.find (fun letter -> letter = str) alphabet
  with e -> failwith (Printf.sprintf "The elemet '%s' not in alphabet" str)

let verify_machine machine =
  ignore (check_single_char_list machine.alphabet "alphabet");
  ignore (check_single_char machine.blank "blank");
  ignore (check_if_in_alphabet machine.blank machine.alphabet);

  string_in_list machine.initial machine.states;
  List.iter
    (fun final_state -> string_in_list final_state machine.states)
    machine.finals;

  let transitions_states =
    Hashtbl.fold (fun state _ acc -> state :: acc) machine.transitions []
  in
  let states_without_finals =
    List.filter (fun x -> not (List.mem x machine.finals)) machine.states
  in
  equal_lists states_without_finals transitions_states;

  Hashtbl.iter
    (fun state transitions_list ->
      string_in_list state machine.states;
      List.iter
        (fun t ->
          check_single_char t.read "read";
          check_single_char t.write "write";
          ignore (check_if_in_alphabet t.read machine.alphabet);
          ignore (check_if_in_alphabet t.write machine.alphabet);
          string_in_list t.to_state machine.states)
        transitions_list)
    machine.transitions

let verify_tape input alphabet =
  let strings =
    List.init (String.length input) (fun i -> String.make 1 input.[i])
  in
  List.iter (fun s -> ignore (check_if_in_alphabet s alphabet)) strings
