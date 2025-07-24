
(* ANSI color codes *)
let green = "\027[32m"
let red = "\027[31m"
let reset = "\027[0m"

(* Test helper functions *)
let assert_equal expected actual message =
  if expected = actual then
    Printf.printf "%s✓ %s%s\n" green message reset
  else
    Printf.printf "%s✗ %s: expected %s, got %s%s\n" red message 
      (match expected with
       | s when String.length s < 50 -> s
       | s -> String.sub s 0 47 ^ "...")
      (match actual with
       | s when String.length s < 50 -> s  
       | s -> String.sub s 0 47 ^ "...")
      reset

let assert_list_equal expected actual message =
  if expected = actual then
    Printf.printf "%s✓ %s%s\n" green message reset
  else
    Printf.printf "%s✗ %s: lists don't match%s\n" red message reset

let assert_exception_raised f message =
  try
    f ();
    Printf.printf "%s✗ %s: expected exception but none was raised%s\n" red message reset
  with
  | e -> Printf.printf "%s✓ %s: %s%s\n" green message (Printexc.to_string e) reset
