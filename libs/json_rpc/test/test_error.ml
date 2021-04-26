open Json_rpc

let yojson = Yojson.Safe.from_file "json/error.json"

let read () =
  let error = Jsonrpc.of_yojson yojson in
  let error =
    match error with
    | Jsonrpc.Response resp -> resp
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let error_t =
    match error.error with
    | Some err -> err
    | None -> raise (Invalid_argument "This should not happen")
  in
  let expected_id = `Int 1 in
  let error_code =
    match Jsonrpc.Error.Code.of_int (-32601) with
    | Some err_code -> err_code
    | None -> raise (Invalid_argument "This should not happen")
  in
  let expected_error =
    Jsonrpc.Error.to_yojson
      {code= error_code; message= "method not found"; data= None}
  in
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check yojson) "check id" expected_id (error.id :> Yojson.Safe.t) ;
  Alcotest.(check yojson)
    "check error" expected_error
    (Jsonrpc.Error.to_yojson error_t)

let write () =
  let error : Jsonrpc.Error.t =
    { code= Jsonrpc.Error.Code.MethodNotFound
    ; message= "method not found"
    ; data= None }
  in
  let error = Jsonrpc.Response.create ?error:(Some error) (`Int 1) in
  let error_json = Jsonrpc.Response.to_yojson error in
  let yojson_eq = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check yojson_eq) "check error" yojson error_json

let test_error = [("Can read error", `Quick, read); ("Can write error", `Quick, write)]
