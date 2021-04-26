open Json_rpc

let yojson = Yojson.Safe.from_file "json/response.json"

let read () =
  let response = Jsonrpc.of_yojson yojson in
  let expected_result =
    `Assoc
      [ ( "uri"
        , `String "file:///p%3A/mseng/VSCode/Playgrounds/cpp/provide.cpp" )
      ; ( "range"
        , `Assoc
            [ ("start", `Assoc [("line", `Int 0); ("character", `Int 4)])
            ; ("end", `Assoc [("line", `Int 0); ("character", `Int 11)]) ] )
      ]
  in
  let expected_id = `Int 1 in
  let current_id =
    match response with
    | Jsonrpc.Response resp -> resp.id
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let current_result =
    match response with
    | Jsonrpc.Response resp -> resp.result
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let current_result =
    match current_result with
    | Some res -> res
    | None -> raise (Invalid_argument "This should not happen")
  in
  let current_error =
    match response with
    | Jsonrpc.Response resp -> (
      match resp.error with
      | Some err -> Jsonrpc.Error.to_yojson err
      | None -> `Null )
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check yojson)
    "check id"
    (current_id :> Yojson.Safe.t)
    expected_id ;
  Alcotest.(check yojson)
    "check result"
    (current_result :> Yojson.Safe.t)
    expected_result ;
  Alcotest.(check yojson)
    "check error"
    (current_error :> Yojson.Safe.t)
    `Null

let write () =
  let id = `Int 1 in
  let result : Jsonrpc.Json.t =
    `Assoc
      [ ( "uri"
        , `String "file:///p%3A/mseng/VSCode/Playgrounds/cpp/provide.cpp" )
      ; ( "range"
        , `Assoc
            [ ("start", `Assoc [("line", `Int 0); ("character", `Int 4)])
            ; ("end", `Assoc [("line", `Int 0); ("character", `Int 11)]) ] )
      ]
  in
  let response = Jsonrpc.Response.create ?result:(Some result) id in
  let yojson_resp = Jsonrpc.Response.to_yojson response in
  let yojson_eq = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check yojson_eq) "is expected JSon" yojson yojson_resp

let test_response =
  [("Can read result", `Quick, read); ("Can write result", `Quick, write)]
