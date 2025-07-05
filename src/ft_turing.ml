open Parsing_json

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
  let has_help =
    List.exists (fun arg -> arg = "-h" || arg = "--help") argv_list
  in
  let args_only =
    List.filter
      (fun arg -> arg <> progname && arg <> "-h" && arg <> "--help")
      argv_list
  in

  match (has_help, args_only) with
  | true, _ -> print_help progname
  | false, [ jsonfile; input ] ->
      let json = Yojson.Safe.from_file jsonfile in
      let machine = Parsing_json.turing_machine_from_json json in
      Parsing_json.print_turing_machine machine
  | _ ->
      print_help progname;
      exit 1
