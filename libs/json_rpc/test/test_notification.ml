open Json_rpc

let yojson = Yojson.Safe.from_file "json/notification.json"

let read () =
  let not = Jsonrpc.of_yojson yojson in
  let not =
    match not with
    | Jsonrpc.Message (Jsonrpc.Message.Notification not) -> not
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let open Yojson.Safe.Util in
  let expected_params = [yojson] |> filter_member "params" in
  let params =
    match not.params with
    | Some params -> params
    | None -> raise (Invalid_argument "This should not happen")
  in
  let expected_params =
    match expected_params with
    | [params] -> params
    | _ -> raise (Invalid_argument "This should not happen")
  in
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check string) "method" not.method_ "$/cancelRequest" ;
  Alcotest.(check yojson) "params" (params :> Yojson.Safe.t) expected_params

let write () =
  let params = Some (`Assoc [("id", `Int 1)]) in
  let method_ = "$/cancelRequest" in
  let not = Jsonrpc.Notification.create ?params method_ in
  let json = Jsonrpc.Notification.to_yojson not in
  let expected_json = yojson in
  let yojson = Alcotest.testable Yojson.Safe.pp Yojson.Safe.equal in
  Alcotest.(check yojson) "write" expected_json json

let test_notification =
  [ ("Can read notification", `Quick, read)
  ; ("Can write notification", `Quick, write) ]
