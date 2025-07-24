open Types

let action_to_sting = function RIGHT -> "RIGHT" | LEFT -> "LEFT"

let print_transition state t =
  Printf.printf "(%s, %s) -> (%s, %s, %s)\n" state t.read t.to_state t.write
    (action_to_sting t.action)

let print_turing_machine tm =
  let border = String.make 80 '*' in
  let center_text text =
    let len = String.length text in
    let padding = (78 - len) / 2 in
    Printf.sprintf "*%s%s%s*" (String.make padding ' ') text
      (String.make (78 - len - padding) ' ')
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
  Printf.printf "%s\n" border;
  Hashtbl.iter
    (fun state transitions ->
      List.iter (fun t -> print_transition state t) transitions)
    tm.transitions;
  Printf.printf "%s\n" border

let print_tape_machine tape_machine transition =
  let left_str = String.concat "" tape_machine.left in
  let right_str = String.concat "" tape_machine.right in
  let string_tape =
    Printf.sprintf "%s<%s>%s" left_str tape_machine.current right_str
  in
  let dots = String.make (String.length string_tape) '.' in
  Printf.printf "[%s%s] " string_tape dots;
  print_transition tape_machine.current_state transition
