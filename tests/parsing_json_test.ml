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
  | e -> Printf.printf "✓ %s: %s\n" message (Printexc.to_string e)

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

let invalid_json_read_not_in_alphabet_string = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "R", "to_state": "q1", "write": "1", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_write_not_in_alphabet_string = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "1", "to_state": "q1", "write": "W", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_blank_not_in_alphabet_string = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "T",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "1", "to_state": "q1", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let multi_char_blank_json_string = {|
{
  "name": "incomplete_machine",
  "alphabet": ["0", "1"],
  "blank": ".1",
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
  Printf.printf "\n=== parsing_valid_transitions ===\n";
  
  let transition_json = from_string {|
    { "read": "0", "to_state": "q1", "write": "1", "action": "RIGHT" }
  |} in
  
  let transition = transitions_of_json transition_json in
  
  assert_equal "0" transition.read "transition read field";
  assert_equal "q1" transition.to_state "transition to_state field";
  assert_equal "1" transition.write "transition write field";
  assert_equal "RIGHT" (action_to_sting transition.action) "transition action field"

let test_alphabet_with_elements_grater_than_single_letter () =
  Printf.printf "\n=== test_alphabet_with_elements_grater_than_single_letter ===\n";
  let json = Yojson.Safe.from_string invalid_alphabet_json_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "the alphabet attribute that contains multi-character strings should raise exception"

(* what is the blank char??? 
definition: The blank character, must be part of the alphabet, must NOT be part of the
input *)
(* this test IS NOT WORKING *)
let test_blank_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_blank_greater_than_one_char_should_throw ===\n";

  let json = Yojson.Safe.from_string multi_char_blank_json_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "the blank attribute that contains multi-character elements should raise exception"

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
    "transitions with an action different than LEFT or RIGHT should raise exception"


(* Deve verificar se
  - o read e o write das transitions existe no alfabeto
  - se o to_state dos transitions existe nos states
  - O nome de cara transiction precisa estar no states
  - se o initial existe no states
  - Se todos os finals existe nos states
  - se o blank existe no alfabero
*)
let test_read_not_in_alphabet_shold_throw () =
  Printf.printf "\n=== test_read_not_in_alphabet_shold_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_read_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "the read attribute that not in alphabet should raise exception"

let test_write_not_in_alphabet_shold_throw () =
  Printf.printf "\n=== test_write_not_in_alphabet_shold_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_write_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "the write attribute that not in alphabet should raise exception"

let test_blank_not_in_alphabet_shold_throw () =
  Printf.printf "\n=== test_blank_not_in_alphabet_shold_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_blank_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (turing_machine_from_json json))
    "the blank attribute that not in alphabet should raise exception"

(* Run all tests *)
let run_tests () =
  Printf.printf "Starting Parsing_json tests...\n";
  Printf.printf "================================\n";
  
  test_parsing_valid_transitions_json ();
  test_alphabet_with_elements_grater_than_single_letter ();
  test_blank_greater_than_one_char_should_throw ();
  test_transitions_with_read_greater_than_one_char_should_throw ();
  test_transitions_with_write_greater_than_one_char_should_throw ();
  test_transitions_with_invalid_action_should_throw ();
  test_read_not_in_alphabet_shold_throw ();
  test_write_not_in_alphabet_shold_throw ();
  test_blank_not_in_alphabet_shold_throw ();
  
  Printf.printf "\n================================\n";
  Printf.printf "Tests completed!\n"

(* Entry point *)
let () = run_tests ()