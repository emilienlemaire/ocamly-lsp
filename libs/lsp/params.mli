open Types
open Json_rpc

module TextDocumentPositionParams : sig
  type t = {textDocument: TextDocumentIdentifier.t; position: Position.t}
end

module WorkDoneProgressParams : sig
  type t = {workDoneToken: ProgressToken.t}
end

module PartialResultParams : sig
  type t = {partialResultToken: ProgressToken.t option}
end

module InitializeParams : sig
  type clientInfo = {name: string; version: string option}

  type documentURI_or_null =
    | DocumentURI of DocumentURI.t
    | Null

  type workspaceFolder_or_null =
    | WorspaceFolder of WorkspaceFolder.t list
    | Null

  type t = {workDoneProgressParams: WorkDoneProgressParams.t
  ; clientInfo: clientInfo option
  ; locale: string option
  ; rootPath: [`String of string | `Null] option
  ; rootUri: documentURI_or_null
  ; initializationOptions: Jsonrpc.Json.t option
  ; capabilities: ClientCapabilities.t
  ; trace: TraceValue.t option;
  ; workspaceFolder: workspaceFolder_or_null option }
end
