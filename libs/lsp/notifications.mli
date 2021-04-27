open Types

module CancelRequest : sig
  type t = Jsonrpc.Id.t
end

module Progress : sig
  type t = {token: ProgessToken.t; value: Jsonrpc.Json.t}
end
