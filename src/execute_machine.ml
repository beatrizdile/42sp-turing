open Types
open Parsing
open Print

(*
  1. Initialize tape: take the input and make into the struct
  2. Iterate through the tape - while true
  3. Make the to_left to_right to create new tape_machine
    3.1. Create visual output for each step on the terminal
  4. Check if current state is final
  5. Check if we're stuck in an infinite loop
*)

let create_initial_tape_machine input current_state =
  let right_list =
    List.init (String.length input - 1) (fun i -> String.make 1 input.[i + 1])
  in
  {
    current_state;
    left = [];
    current = String.make 1 input.[0];
    right = right_list;
  }

let split_last lst =
  match List.rev lst with
  | [] -> failwith "Empty list"
  | x :: rest -> (List.rev rest, x)

let split_first lst =
  match lst with [] -> failwith "Empty list" | x :: rest -> (rest, x)

let move transition tape_machine =
  match transition.action with
  | LEFT ->
      let left, current = split_last tape_machine.left in
      {
        current_state = transition.to_state;
        left;
        current;
        right = transition.write :: tape_machine.right;
      }
  | RIGHT ->
      let right, current = split_first tape_machine.right in
      {
        current_state = transition.to_state;
        left = tape_machine.left @ [ transition.write ];
        current;
        right;
      }

let execute_machine machine input =
  let tape_machine = ref (create_initial_tape_machine input machine.initial) in
  let is_running = ref true in
  while !is_running do
    let state_transition =
      Hashtbl.find machine.transitions !tape_machine.current_state
    in
    let transition =
      List.find
        (fun transition -> transition.read = !tape_machine.current)
        state_transition
    in
    print_tape_machine !tape_machine transition;
    tape_machine := move transition !tape_machine;
    is_running :=
      not
        (List.exists
           (fun final -> final = !tape_machine.current_state)
           machine.finals)
  done
