open Json_rpc

let yojson = Yojson.Safe.from_file "json/request.json"

let read () =
  print_endline (Sys.getcwd ()) ;
  let req : Jsonrpc.t = Jsonrpc.of_yojson yojson in
  let req =
    match req with
    | Jsonrpc.Message (Jsonrpc.Message.Request req) -> req
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let ({id; method_; params} : Jsonrpc.Request.t) = req in
  let id =
    match id with
    | `Int id -> id
    | _ -> raise (Invalid_argument "This sould never happen")
  in
  let open Yojson.Safe.Util in
  let expected_params = [yojson] |> filter_member "params" in
  let expected_params =
    match expected_params with
    | [params] -> params
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let params =
    match params with
    | Some params -> params
    | None -> raise (Invalid_argument "This should not happen")
  in
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check int) "Equal id" 1 id ;
  Alcotest.(check string) "Equal method" "textDocument/definition" method_ ;
  Alcotest.(check yojson)
    "Equal params"
    (params :> Yojson.Safe.t)
    expected_params

let write () =
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  let expected_json = Yojson.Safe.from_file "json/request.json" in
  let req : Jsonrpc.Request.t =
    { id= `Int 1
    ; method_= "textDocument/definition"
    ; params=
        Some
          (`Assoc
            [ ( "textDocument"
              , `Assoc
                  [ ( "uri"
                    , `String
                        "file:///p%3A/mseng/VSCode/Playgrounds/cpp/use.cpp"
                    ) ] )
            ; ("position", `Assoc [("line", `Int 3); ("character", `Int 12)])
            ] ) }
  in
  let actual_json = Jsonrpc.Request.to_yojson req in
  Alcotest.(check yojson) "to yojson" expected_json actual_json

let test_request =
  [("Can read request", `Quick, read); ("Can write request", `Quick, write)]
