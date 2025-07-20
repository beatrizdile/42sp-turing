type action_type = RIGHT | LEFT

type transitions = {
  read : string;
  to_state : string;
  write : string;
  action : action_type;
}

type turing_machine = {
  name : string;
  alphabet : string list;
  blank : string;
  states : string list;
  initial : string;
  finals : string list;
  transitions : (string, transitions list) Hashtbl.t;
}

type tape_machine = {
  current_state : string;
  left : string list;
  current : string;
  right : string list;
}
