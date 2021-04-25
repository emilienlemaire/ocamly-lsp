open Json_rpc

let () =
  let yojson = Yojson.Safe.from_file "src/test.json" in
  let _ = print_endline (Yojson.Safe.pretty_to_string yojson) in
  let jsonrpc = Jsonrpc.of_yojson yojson in
  let yojson = Jsonrpc.to_yojson jsonrpc in
  print_endline (Yojson.Safe.pretty_to_string yojson)
