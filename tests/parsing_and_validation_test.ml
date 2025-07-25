open Parsing
open Validation
open Print
open Yojson.Safe
open Test_utils

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
      { "read": "R", "to_state": "q0", "write": "1", "action": "RIGHT" }
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
      { "read": "1", "to_state": "q0", "write": "W", "action": "RIGHT" }
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
      { "read": "1", "to_state": "q0", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_finals_states_not_in_states_list = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "0",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT", "INVALID"],
  "transitions": {
    "q0": [
      { "read": "1", "to_state": "HALT", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_initial_state_not_in_states_list = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "0",
  "states": ["q0", "HALT"],
  "initial": "INVALID",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "1", "to_state": "q0", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

(*
  Important: the final states don't need to be specified in "transitions", 
  given that they are the states we stop our machine.

  So, in this example the missing state in transitions is "INVALID" - NOT "other"
  We don't need to specify "other" because it's a final state of the machine.
*)
let invalid_json_states_that_dont_exist_in_transitions = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "0",
  "states": ["dummy", "other", "INVALID"],
  "initial": "dummy",
  "finals": ["other"],
  "transitions": {
    "dummy": [
      { "read": "1", "to_state": "other", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_transitions_that_dont_exist_in_states = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "0",
  "states": ["dummy", "another"],
  "initial": "dummy",
  "finals": ["another"],
  "transitions": {
    "dummy": [
      { "read": "1", "to_state": "another", "write": "0", "action": "RIGHT" }
    ],
    "INVALID": [
      { "read": "1", "to_state": "dummy", "write": "0", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_json_transitions_to_state_that_dont_exist_in_states = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": "0",
  "states": ["dummy", "other", "another", "final"],
  "initial": "dummy",
  "finals": ["other", "final"],
  "transitions": {
    "dummy": [
      { "read": "1", "to_state": "other", "write": "0", "action": "RIGHT" }
    ],
    "another": [
      { "read": "1", "to_state": "INVALID", "write": "0", "action": "RIGHT" }
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

let invalid_transiction_state_name = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "0", "to_state": "HALT", "write": "0", "action": "RIGHT" }
    ],
    "INVALID": [
      { "read": "1", "to_state": "q0", "write": "1", "action": "LEFT" }
    ]
  }
}
|}

let invalid_read_value_name = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "01", "to_state": "HALT", "write": "1", "action": "RIGHT" }
    ]
  }
}
|}

let invalid_write_value_name = {|
{
  "name": "test_machine",
  "alphabet": ["0", "1", "."],
  "blank": ".",
  "states": ["q0", "HALT"],
  "initial": "q0",
  "finals": ["HALT"],
  "transitions": {
    "q0": [
      { "read": "0", "to_state": "HALT", "write": "10", "action": "RIGHT" }
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
  
  let transition = transition_from_json transition_json in
  
  assert_equal "0" transition.read "transition read field";
  assert_equal "q1" transition.to_state "transition to_state field";
  assert_equal "1" transition.write "transition write field";
  assert_equal "RIGHT" (action_to_sting transition.action) "transition action field"

let test_alphabet_with_elements_greater_than_single_letter () =
  Printf.printf "\n=== test_alphabet_with_elements_greater_than_single_letter ===\n";
  let json = Yojson.Safe.from_string invalid_alphabet_json_string in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the alphabet attribute that contains multi-character strings should raise exception"

(* Blank definition: The blank character, must be part of the alphabet, must NOT be part of the input *)
let test_blank_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_blank_greater_than_one_char_should_throw ===\n";

  let json = Yojson.Safe.from_string multi_char_blank_json_string in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the blank attribute that contains multi-character elements should raise exception"

let test_transitions_with_read_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_transitions_with_read_greater_than_one_char_should_throw ===\n";
  
  let json = Yojson.Safe.from_string invalid_read_value_name in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "transitions with a read attribute that contains multi-character elements should raise exception"

let test_transitions_with_write_greater_than_one_char_should_throw () =
  Printf.printf "\n=== test_transitions_with_write_greater_than_one_char_should_throw ===\n";
  
  let json = Yojson.Safe.from_string invalid_write_value_name in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "transitions with a write attribute that contains multi-character elements should raise exception"


let test_transitions_with_invalid_action_should_throw () =
  Printf.printf "\n=== test_transitions_with_invalid_action_should_throw ===\n";
  
  let transition_read_greater_than_one = from_string {|
    { "read": "0", "to_state": "q1", "write": "1", "action": "DOWN" }
  |} in

  let json = transition_read_greater_than_one in
  assert_exception_raised 
    (fun () -> ignore (transitions_from_json json))
    "transitions with an action different than LEFT or RIGHT should raise exception"

let test_read_not_in_alphabet_should_throw () =
  Printf.printf "\n=== test_read_not_in_alphabet_should_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_read_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the read attribute that is not in alphabet should raise exception"

let test_write_not_in_alphabet_should_throw () =
  Printf.printf "\n=== test_write_not_in_alphabet_should_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_write_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the write attribute that is not in alphabet should raise exception"

let test_blank_not_in_alphabet_should_throw () =
  Printf.printf "\n=== test_blank_not_in_alphabet_should_throw ===\n";

  let json = Yojson.Safe.from_string invalid_json_blank_not_in_alphabet_string in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the blank attribute that is not in alphabet should raise exception"

let test_initial_state_not_in_states_list_should_throw () =
  Printf.printf "\n=== test_initial_state_not_in_states_list ===\n";

  let json = Yojson.Safe.from_string invalid_json_initial_state_not_in_states_list in
  assert_exception_raised 
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the initial state that is not in states list should raise exception"

let test_finals_states_not_in_states_list_should_throw () =
  Printf.printf "\n=== test_finals_states_not_in_states_list ===\n";

  let json = Yojson.Safe.from_string invalid_json_finals_states_not_in_states_list in
  assert_exception_raised
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the final state that is not in states list should raise exception"

(* Important: the final states don't need to be specified in "transitions",
  given that they are the states we stop our machine. *)
let test_if_all_states_exist_in_transitions () =
  Printf.printf "\n=== test_if_all_states_exist_in_transitions ===\n";

  let json = Yojson.Safe.from_string invalid_json_states_that_dont_exist_in_transitions in
  assert_exception_raised
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the state that is not in transitions should raise exception"

let test_if_all_transitions_exist_in_states () =
  Printf.printf "\n=== test_if_all_transitions_exist_in_states ===\n";

  let json = Yojson.Safe.from_string invalid_json_transitions_that_dont_exist_in_states in
  assert_exception_raised
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the state that is not in transitions should raise exception"

let test_if_transitions_to_state_exist_in_states () =
  Printf.printf "\n=== test_if_transitions_to_state_exist_in_states ===\n";

  let json = Yojson.Safe.from_string invalid_json_transitions_to_state_that_dont_exist_in_states in
  assert_exception_raised
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "the transitions.to_state that is not in states should raise exception"

let test_transition_key_not_in_states_should_throw () =
  Printf.printf "\n=== test_transition_key_not_in_states_should_throw ===\n";
  let json = Yojson.Safe.from_string invalid_transiction_state_name in
  assert_exception_raised
    (fun () -> ignore (json |> turing_machine_from_json |> verify_machine))
    "transition key not in states should raise exception"
  
let test_verify_tape_in_alphabet () =
  Printf.printf "\n=== test_verify_tape_in_alphabet ===\n";
  let input = "aeiou" in
  let alphabet = ["a"; "e"; "i"; "o"] in
  assert_exception_raised
    (fun () -> ignore (verify_tape input alphabet))
    "input tape not in alphabet should raise exception"

(* Run all tests *)
let run_tests () =
  Printf.printf "Starting Parsing_and_validation tests...\n";
  Printf.printf "================================\n";
  
  test_parsing_valid_transitions_json ();
  test_alphabet_with_elements_greater_than_single_letter ();
  test_blank_greater_than_one_char_should_throw ();
  test_transitions_with_read_greater_than_one_char_should_throw ();
  test_transitions_with_write_greater_than_one_char_should_throw ();
  test_transitions_with_invalid_action_should_throw ();
  test_read_not_in_alphabet_should_throw ();
  test_write_not_in_alphabet_should_throw ();
  test_blank_not_in_alphabet_should_throw ();
  test_initial_state_not_in_states_list_should_throw ();
  test_finals_states_not_in_states_list_should_throw ();
  test_if_all_states_exist_in_transitions ();
  test_if_all_transitions_exist_in_states ();
  test_if_transitions_to_state_exist_in_states ();
  test_transition_key_not_in_states_should_throw ();
  test_verify_tape_in_alphabet ();
  
  Printf.printf "\n================================\n";
  Printf.printf "Tests completed!\n"

(* Entry point *)
let () = run_tests ()
