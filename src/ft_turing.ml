open Parsing_json

let print_help progname =
  Printf.printf "usage: %s [-h] jsonfile input\n\
positional arguments:\n\
  jsonfile      json description of the machine\n\
  input         input of the machine\n\
optional arguments:\n\
  -h, --help    show this help message and exit\n" progname

let () =
  let argv_list = Array.to_list Sys.argv in
  let progname = List.hd argv_list in
  let has_help = List.exists (fun arg -> arg = "-h" || arg = "--help") argv_list in
  let args_only = List.filter (fun arg -> arg <> progname && arg <> "-h" && arg <> "--help") argv_list in

  match has_help, args_only with
  | true, _ -> print_help progname
  | false, [jsonfile; input] ->
    let json = Yojson.Safe.from_file jsonfile in
	  let machine = Parsing_json.turing_machine_from_json json in
    Parsing_json.print_turing_machine machine

  | _ ->
      prerr_endline "Error: you must provide exactly two positional arguments.";
      print_help progname;
      exit 1
