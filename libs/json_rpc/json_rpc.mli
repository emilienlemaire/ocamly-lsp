module Jsonrpc : sig
  module Json : sig
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

  module Error : sig
    module Code : sig
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

      val of_int : int -> t option

      val to_int : t -> int

      val of_yojson : Yojson.Safe.t -> Json.t
    end

    type t = {code: Code.t; message: string; data: Json.t option}

    val to_yojson : t -> Yojson.Safe.t

    exception Of_json of (string * Json.t)

    exception Of_response of string

    exception Of_message of string
  end

  module Id : sig
    type t = [`String of string | `Int of int | `Null]

    val of_yojson : Yojson.Safe.t -> t option
  end

  module Structured : sig
    type t = [`Assoc of (string * Json.t) list | `List of Json.t list]

    val of_yojson : Yojson.Safe.t -> t
  end

  module Request : sig
    type t = {id: Id.t; method_: string; params: Structured.t option}

    val to_yojson : t -> Yojson.Safe.t

    val create : ?params:Structured.t -> Id.t -> string -> t
  end

  module Notification : sig
    type t = {method_: string; params: Structured.t option}

    val to_yojson : t -> Yojson.Safe.t

    val create : ?params:Structured.t -> string -> t
  end

  module Message : sig
    type t = Request of Request.t | Notification of Notification.t

    val to_yojson : t -> Yojson.Safe.t

    val create : ?id:Id.t -> ?params:Structured.t -> string -> t
  end

  module Response : sig
    type t = {id: Id.t; result: Json.t option; error: Error.t option}

    val to_yojson : t -> Yojson.Safe.t

    val create : ?error:Error.t -> ?result:Json.t -> Id.t -> t
  end

  type t = Message of Message.t | Response of Response.t

  val of_yojson : Yojson.Safe.t -> t

  val to_yojson : t -> Yojson.Safe.t
end
