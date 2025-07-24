open Types
open Parsing
open Validation
open Execute_machine
open Print

let print_help progname =
  Printf.printf "usage: %s [-h] jsonfile input\n" progname;
  Printf.printf "positional arguments:\n";
  Printf.printf "  jsonfile      json description of the machine\n";
  Printf.printf "  input         input of the machine\n";
  Printf.printf "optional arguments:\n";
  Printf.printf "  -h, --help    show this help message and exit\n"

let () =
  let argv_list = Array.to_list Sys.argv in
  let progname = List.hd argv_list in
  let help_input =
    List.exists (fun arg -> arg = "-h" || arg = "--help") argv_list
  in
  let args_input =
    List.filter
      (fun arg -> arg <> progname && arg <> "-h" && arg <> "--help")
      argv_list
  in

  match (help_input, args_input) with
  | true, _ -> print_help progname
  | false, [ jsonfile; input ] ->
      let json = Yojson.Safe.from_file jsonfile in
      let machine = turing_machine_from_json json in
      verify_machine machine;
      print_turing_machine machine;
      verify_tape input machine.alphabet;
      execute_machine machine input
  | _ ->
      print_help progname;
      exit 1
