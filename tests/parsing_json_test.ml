open Parsing_json
open Yojson.Safe

(* Test helper functions *)
let assert_equal expected actual message =
  if expected = actual then
    Printf.printf "✓ %s\n" message
  else
    Printf.printf "✗ %s: expected %s, got %s\n" message 
      (match expected with
       | s when String.length s < 50 -> s
       | s -> String.sub s 0 47 ^ "...")
      (match actual with
       | s when String.length s < 50 -> s  
       | s -> String.sub s 0 47 ^ "...")

let assert_list_equal expected actual message =
  if expected = actual then
    Printf.printf "✓ %s\n" message
  else
    Printf.printf "✗ %s: lists don't match\n" message

let assert_exception_raised f message =
  try
    f ();
    Printf.printf "✗ %s: expected exception but none was raised\n" message
  with
  | _ -> Printf.printf "✓ %s\n" message

(* Test data *)
let valid_json_string = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "q1", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "0", "to_state": "q1", "write": "1", "action": "RIGHT" },
      { "read": "1", "to_state": "q0", "write": "0", "action": "LEFT" }
    ],
    "q1": [
      { "read": ".", "to_state": "HALT", "write": ".", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_alphabet_json_string = {|
{
  "name": "invalid_machine",
  "alphabet": ["0", "11", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "0", "to_state": "HALT", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let missing_field_json_string = {|
{
  "name": "incomplete_machine",
  "alphabet": ["0", "1"],
  "blank": ".",
  "states": ["q0", "HALT"],
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "0", "to_state": "HALT", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

(* Test functions *)
let test_parsing_valid_transitions_json () =
  Printf.printf "\n=== Testing parsing_valid_transitions ===\n";
  
  let transition_json = from_string {|
    { "read": "0", "to_state": "q1", "write": "1", "action": "RIGHT" }
  |} in
  
  let transition = transitions_of_json transition_json in
  
  assert_equal "0" transition.read "transition read field";
  assert_equal "q1" transition.to_state "transition to_state field";
  assert_equal "1" transition.write "transition write field";
  assert_equal "RIGHT" transition.action "transition action field"

let test_transitions_with_read_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_transitions_with_read_greater_than_one_char_should_throw ===\n";
  
  let transition_read_greater_than_one = from_string {|
    { "read": "01", "to_state": "q1", "write": "1", "action": "RIGHT" }
  |} in

  let json = transition_read_greater_than_one in
  assert_exception_raised 
    (fun () -> ignore (transitions_of_json json))
    "transitions with a read attribute that contains multi-character elements should raise exception"

let test_transitions_with_write_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_transitions_with_write_greater_than_one_char_should_throw ===\n";
  
  let transition_read_greater_than_one = from_string {|
    { "read": "0", "to_state": "q1", "write": "12", "action": "RIGHT" }
  |} in

  let json = transition_read_greater_than_one in
  assert_exception_raised 
    (fun () -> ignore (transitions_of_json json))
    "transitions with a write attribute that contains multi-character elements should raise exception"


let test_transitions_with_invalid_action_should_throw () =
  Printf.printf "\n=== test_transitions_with_invalid_action_should_throw ===\n";
  
  let transition_read_greater_than_one = from_string {|
    { "read": "0", "to_state": "q1", "write": "1", "action": "DOWN" }
  |} in

  let json = transition_read_greater_than_one in
  assert_exception_raised 
    (fun () -> ignore (transitions_of_json json))
    "transitions with an action different than left or right should raise exception"

(* 
let test_valid_turing_machine_parsing () =
  Printf.printf "\n=== Testing valid Turing machine parsing ===\n";
  
  let json = from_string valid_json_string in
  let tm = turing_machine_from_json json in
  
  assert_equal "test_machine" tm.name "machine name";
  assert_list_equal ["0"; "1"; "."] tm.alphabet "alphabet";
  assert_equal "." tm.blank "blank symbol";
  assert_list_equal ["q0"; "q1"; "HALT"] tm.states "states";
  assert_equal "q0" tm.initial "initial state";
  assert_list_equal ["HALT"] tm.finals "final states";
  (* Test transitions *)
  let q0_transitions = Hashtbl.find tm.transitions "q0" in
  assert_equal (string_of_int 2) (string_of_int (List.length q0_transitions)) "number of q0 transitions";
  
  let q1_transitions = Hashtbl.find tm.transitions "q1" in
  assert_equal (string_of_int 1) (string_of_int (List.length q1_transitions)) "number of q1 transitions";
  
  (* Test specific transition *)
  let first_q0_trans = List.hd q0_transitions in
  assert_equal "0" first_q0_trans.read "first q0 transition read";
  assert_equal "q1" first_q0_trans.to_state "first q0 transition to_state";
  assert_equal "1" first_q0_trans.write "first q0 transition write";
  assert_equal "RIGHT" first_q0_trans.action "first q0 transition action"

let test_invalid_alphabet () =
  Printf.printf "\n=== Testing invalid alphabet (multi-character) ===\n";
  
  let json = from_string invalid_alphabet_json_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "alphabet with multi-character elements should raise exception"

let test_missing_fields () =
  Printf.printf "\n=== Testing missing required fields ===\n";
  
  let json = from_string missing_field_json_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "missing 'initial' field should raise exception"

let test_empty_transitions () =
  Printf.printf "\n=== Testing machine with empty transitions ===\n";
  
  let empty_transitions_json = {|
  {
    "name": "empty_machine",
    "alphabet": ["0", "1"],
    "blank": "0",
    "states": ["q0"],
    "initial": "q0",
    "finals": ["q0"],
    "transitions": {}
  }
  |} in
  
  let json = from_string empty_transitions_json in
  let tm = turing_machine_from_json json in
  
  assert_equal "empty_machine" tm.name "empty machine name";
  assert_equal (string_of_int 0) (string_of_int (Hashtbl.length tm.transitions)) "empty transitions table"

let test_complex_machine () =
  Printf.printf "\n=== Testing complex machine (unary_sub.json) ===\n";
  
  let json = from_file "../res/unary_sub.json" in
  let tm = turing_machine_from_json json in
  
  assert_equal "bea_machine" tm.name "complex machine name";
  assert_list_equal ["1"; "."; "-"; "="] tm.alphabet "complex machine alphabet";
  assert_equal "." tm.blank "complex machine blank";
  assert_list_equal ["scanright"; "eraseone"; "subone"; "skip"; "HALT"] tm.states "complex machine states";
  assert_equal "scanright" tm.initial "complex machine initial";
  assert_list_equal ["HALT"] tm.finals "complex machine finals";
  
  (* Verify all states have transitions *)
  let expected_states_with_transitions = ["scanright"; "eraseone"; "subone"; "skip"] in
  List.iter (fun state ->
    if Hashtbl.mem tm.transitions state then
      Printf.printf "✓ State %s has transitions\n" state
    else
      Printf.printf "✗ State %s missing transitions\n" state
  ) expected_states_with_transitions *)

(* Run all tests *)
let run_tests () =
  Printf.printf "Starting Parsing_json tests...\n";
  Printf.printf "================================\n";
  
  test_parsing_valid_transitions_json ();
  test_transitions_with_read_greater_than_one_char_should_throw ();
  test_transitions_with_write_greater_than_one_char_should_throw ();
  test_transitions_with_invalid_action_should_throw ();
  
  Printf.printf "\n================================\n";
  Printf.printf "Tests completed!\n"

(* Entry point *)
let () = run_tests ()