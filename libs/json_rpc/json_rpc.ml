open Yojson.Safe.Util

module Jsonrpc = struct
  module Json = struct
    type t =
      [ `Assoc of (string * t) list
      | `Bool of bool
      | `Float of float
      | `Int of int
      | `Intlit of string
      | `List of t list
      | `Null
      | `String of string
      | `Tuple of t list
      | `Variant of string * t option ]
  end

  module Error = struct
    module Code = struct
      type t =
        | ParseError
        | InvalidRequest
        | MethodNotFound
        | InvalidParams
        | InternalError
        | ServerErrorStart
        | ServerErrorEnd
        | ServerNotInitialized
        | UnknownErrorCode
        | RequestCancelled
        | ContentModified

      let of_int = function
        | -32700 -> Some ParseError
        | -32600 -> Some InvalidRequest
        | -32601 -> Some MethodNotFound
        | -32602 -> Some InvalidParams
        | -32603 -> Some InternalError
        | -32099 -> Some ServerErrorStart
        | -32000 -> Some ServerErrorEnd
        | -32002 -> Some ServerNotInitialized
        | -32001 -> Some UnknownErrorCode
        | -32800 -> Some RequestCancelled
        | -32801 -> Some ContentModified
        | _ -> None

      let to_int = function
        | ParseError -> -32700
        | InvalidRequest -> -32600
        | MethodNotFound -> -32601
        | InvalidParams -> -32602
        | InternalError -> -32603
        | ServerErrorStart -> -32099
        | ServerErrorEnd -> -32000
        | ServerNotInitialized -> -32002
        | UnknownErrorCode -> -32001
        | RequestCancelled -> -32800
        | ContentModified -> -32801

      let rec of_yojson yojson : Json.t =
        match yojson with
        | `Assoc xs -> `Assoc (List.map (fun (s, v) -> (s, of_yojson v)) xs)
        | `Bool b -> `Bool b
        | `Float f -> `Float f
        | `Int i -> `Int i
        | `Intlit il -> `Intlit il
        | `List l -> `List (List.map of_yojson l)
        | `Null -> `Null
        | `String s -> `String s
        | `Tuple t -> `Tuple (List.map of_yojson t)
        | `Variant v -> `Variant v
    end

    type t = {code: Code.t; message: string; data: Json.t option}

    let to_yojson ({code; message; data} : t) =
      match data with
      | Some data ->
          `Assoc
            [ ("code", `Int (Code.to_int code))
            ; ("message", `String message)
            ; ("data", (data :> Json.t)) ]
      | None ->
          `Assoc
            [("code", `Int (Code.to_int code)); ("message", `String message)]

    exception Of_json of (string * Json.t)

    exception Of_response of string

    exception Of_message of string
  end

  module Id = struct
    type t = [`String of string | `Int of int | `Null]

    let of_yojson yojson =
      match yojson with
      | `String s -> Some (`String s)
      | `Int i -> Some (`Int i)
      | `Null -> Some `Null
      | _ -> None
  end

  module Structured = struct
    type t = [`Assoc of (string * Json.t) list | `List of Json.t list]

    let of_yojson = function
      | `Assoc xs -> `Assoc xs
      | `List l -> `List l
      | json -> raise (Error.Of_json ("Invalid structured format", json))
  end

  module Request = struct
    type t = {id: Id.t; method_: string; params: Structured.t option}

    let to_yojson req =
      let yojson =
        [ ("jsonrpc", `String "2.0")
        ; ("id", (req.id :> Yojson.Safe.t))
        ; ("method", `String req.method_) ]
      in
      match req.params with
      | None -> `Assoc yojson
      | Some params ->
          `Assoc (yojson @ [("params", (params :> Yojson.Safe.t))])

    let create ?params id method_ = {id; method_; params}
  end

  module Notification = struct
    type t = {method_: string; params: Structured.t option}

    let to_yojson not =
      let yojson =
        [("jsonrpc", `String "2.0"); ("method", `String not.method_)]
      in
      let yojson =
        match not.params with
        | None -> yojson
        | Some params -> yojson @ [("params", (params :> Yojson.Safe.t))]
      in
      `Assoc yojson

    let create ?params method_ = {method_; params}
  end

  module Message = struct
    type t = Request of Request.t | Notification of Notification.t

    let to_yojson = function
      | Request req -> Request.to_yojson req
      | Notification not -> Notification.to_yojson not

    let create ?id ?params method_ =
      match id with
      | Some v -> Request (Request.create ?params v method_)
      | None -> Notification (Notification.create ?params method_)
  end

  module Response = struct
    type t = {id: Id.t; result: Json.t option; error: Error.t option}

    let to_yojson {id; error; result} =
      let yojson = [("jsonrpc", `String "2.0")] in
      let yojson =
        match (error, result) with
        | Some err, None -> yojson @ [("error", Error.to_yojson err)]
        | None, Some res -> yojson @ [("result", (res :> Yojson.Safe.t))]
        | _ ->
            raise
              (Error.Of_response
                 "There must be at least an error or result object, and not \
                  both of them" )
      in
      `Assoc yojson

    let create ?error ?result id = {id; error; result}
  end

  type t = Message of Message.t | Response of Response.t

  let check_jsonrpc json =
    let jsonrpc = [json] |> filter_member "jsonrpc" |> filter_string in
    match jsonrpc with ["2.0"] -> Ok () | _ -> Error ()

  let get_id_or_none json =
    let id = [json] |> filter_member "id" in
    match id with
    | [id] ->
        Some
          ( match Id.of_yojson id with
          | Some id -> id
          | None ->
              raise
                (Error.Of_json
                   ( "The id field must be a string, int or null if set."
                   , json ) ) )
    | [] -> None
    | _ -> raise (Error.Of_json ("There must be at most 1 'id' field", json))
  (*Really only 0 is left List.length is unsigned*)

  let get_params_or_none json =
    let params = [json] |> filter_member "params" in
    match params with
    | [params] -> Some (Structured.of_yojson params)
    | [] -> None
    | _ ->
        raise
          (Error.Of_json ("There must be at most one 'params' field.", json))

  let get_method_or_none json =
    let method_ = [json] |> filter_member "method" |> filter_string in
    match method_ with
    | [method_] -> Some method_
    | [] -> None
    | _ ->
        raise
          (Error.Of_json ("There must be exactly one 'method' field.", json))

  let filter_error json =
    let code = [json] |> filter_member "code" |> filter_int in
    let code =
      match code with
      | [code] -> (
        match Error.Code.of_int code with
        | Some code_t -> code_t
        | None ->
            raise
              (Error.Of_json
                 (Printf.sprintf "Undefined error code: %d" code, json) ) )
      | _ ->
          raise
            (Error.Of_json
               ( "There must be exactly one 'code' field with an int inside"
               , json ) )
    in
    let message = [json] |> filter_member "message" |> filter_string in
    let message =
      match message with
      | [message] -> message
      | _ ->
          raise
            (Error.Of_json
               ( "There must be exactly one 'message' field with a string \
                  inside"
               , json ) )
    in
    let data = [json] |> filter_member "data" in
    let data =
      match data with
      | [data] -> Some (data :> Json.t)
      | [] -> None
      | _ ->
          raise
            (Error.Of_json ("There must be at most one 'data' field.", json))
    in
    let err : Error.t = {code; message; data} in
    err

  let get_error_or_none json =
    let error = [json] |> filter_member "error" in
    match error with
    | [error] -> Some (filter_error error)
    | [] -> None
    | _ ->
        raise
          (Error.Of_json ("There must be at most one 'error' field.", json))

  let get_result_of_none json =
    let result = [json] |> filter_member "result" in
    match result with
    | [result] -> Some (result :> Json.t)
    | [] -> None
    | _ ->
        raise
          (Error.Of_json ("There must be at most one 'result' field.", json))

  let of_yojson yojson =
    let _ =
      match check_jsonrpc yojson with
      | Ok _ -> ()
      | Error _ -> raise (Error.Of_json ("Invalid 'jsonrpc' field", yojson))
    in
    let id = get_id_or_none yojson in
    let params = get_params_or_none yojson in
    let method_ = get_method_or_none yojson in
    let error = get_error_or_none yojson in
    let result = get_result_of_none yojson in
    match (method_, error, result, id) with
    | None, Some _, None, Some id ->
        Response (Response.create ?error ?result id)
    | None, None, Some _, Some id ->
        Response (Response.create ?error ?result id)
    | Some method_, None, None, _ ->
        Message (Message.create ?id ?params method_)
    | None, None, None, _ ->
        raise
          (Error.Of_json
             ( "There must be one of these fields: 'method', 'error' or \
                'result'."
             , yojson ) )
    | None, Some _, Some _, _ ->
        raise
          (Error.Of_json
             ( "There must be either the field 'error' or 'result', but not \
                both"
             , yojson ) )
    | Some _, Some _, _, _ ->
        raise
          (Error.Of_json
             ( "There must be either the field 'method' of 'error' but not \
                both"
             , yojson ) )
    | Some _, _, Some _, _ ->
        raise
          (Error.Of_json
             ( "There must be either the field 'method' or 'result' but not \
                both"
             , yojson ) )
    | None, Some _, None, None | None, None, Some _, None ->
        raise
          (Error.Of_json
             ("There must be the field 'id' in a response object.", yojson)
          )

  exception Not_implemented_yet

  let to_yojson = function
    | Message (Message.Request req) -> (
        let yojson =
          [ ("jsonrpc", `String "2.0")
          ; ("id", (req.id :> Yojson.Safe.t))
          ; ("method", `String req.method_) ]
        in
        match req.params with
        | Some params ->
            let yojson = yojson @ [("params", (params :> Yojson.Safe.t))] in
            `Assoc yojson
        | None -> `Assoc yojson )
    | Message (Message.Notification not) -> (
        let yojson =
          [("jsonrpc", `String "2.0"); ("method", `String not.method_)]
        in
        match not.params with
        | Some params ->
            let yojson = yojson @ [("params", (params :> Yojson.Safe.t))] in
            `Assoc yojson
        | None -> `Assoc yojson )
    | Response _ -> raise Not_implemented_yet
end
