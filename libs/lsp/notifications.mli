open Json_rpc

module CancelRequest : sig
  type t = Jsonrpc.Id.t
end

module Progress : sig
  type token = [`Int of int | `String of string]

  type t = {token: token; value: Jsonrpc.Json.t}
end
