open Types

let action_to_sting = function RIGHT -> "RIGHT" | LEFT -> "LEFT"

let print_transition t =
  Printf.printf "    { read = %s; to_state = %s; write = %s; action = %s }\n"
    t.read t.to_state t.write (action_to_sting t.action)

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
            t.write (action_to_sting t.action))
        transitions)
    tm.transitions
