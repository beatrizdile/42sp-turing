open Types
open Parsing
open Print

let create_initial_tape_machine input current_state blank =
  let right_list =
    if String.length input > 1 then
      List.init (String.length input - 1) (fun i -> String.make 1 input.[i + 1])
    else []
  in
  {
    current_state;
    left = [ blank ];
    current = String.make 1 input.[0];
    right = right_list @ [ blank ];
  }

let split_last lst =
  match List.rev lst with
  | [] -> failwith "Empty list"
  | x :: rest -> (List.rev rest, x)

let split_first lst =
  match lst with [] -> failwith "Empty list" | x :: rest -> (rest, x)

let move transition tape_machine blank =
  match transition.action with
  | LEFT -> (
      match tape_machine.left with
      | [] ->
          {
            current_state = transition.to_state;
            left = [ blank ];
            current = blank;
            right = transition.write :: tape_machine.right;
          }
      | _ ->
          let left, current = split_last tape_machine.left in
          {
            current_state = transition.to_state;
            left;
            current;
            right = transition.write :: tape_machine.right;
          })
  | RIGHT -> (
      match tape_machine.right with
      | [] ->
          {
            current_state = transition.to_state;
            left = tape_machine.left @ [ transition.write ];
            current = blank;
            right = [ blank ];
          }
      | _ ->
          let right, current = split_first tape_machine.right in
          {
            current_state = transition.to_state;
            left = tape_machine.left @ [ transition.write ];
            current;
            right;
          })

let execute_machine machine input =
  let tape_machine =
    ref (create_initial_tape_machine input machine.initial machine.blank)
  in
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
    print_tape_state_machine !tape_machine transition;
    tape_machine := move transition !tape_machine machine.blank;
    is_running :=
      not
        (List.exists
           (fun final -> final = !tape_machine.current_state)
           machine.finals)
  done;
  print_tape_machine !tape_machine;
  Printf.printf "\n"
