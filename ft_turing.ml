let () =
  let args = Array.to_list Sys.argv in
  match args with
  | _ :: json_filename :: _ ->
	  let json = Yojson.Safe.from_file json_filename in
	  let name = Yojson.Safe.Util.(json |> member "name" |> to_string) in
	  print_endline name
  | _ ->
      Printf.printf "usage: ft_turing [-h] jsonfile input\n\npositional arguments:\njsonfile \tjson description of the machine\n\ninput \t\tinput of the machine\n\noptional arguments:\n-h, --help \tshow this help message and exit\n"

