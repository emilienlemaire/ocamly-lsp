open Json_rpc

module DocumentUri : sig
  type t = [`String of string]
end

module URI : sig
  type t = [`String of string]
end

module Position : sig
  type t = {line: int; character: int}
end

module Range : sig
  type t = {start: Position.t; end_: Position.t}
end

module Location : sig
  type t = {uri: DocumentUri.t; range: Range.t}
end

module LocationLink : sig
  type t =
    { originSelectionRange: Range.t option
    ; targetUri: DocumentUri.t
    ; targetRange: Range.t
    ; targetSelectionRange: Range.t }
end

module DiagnosticSeverity : sig
  type t =
    | Error
    | Warning
    | Information
    | Hint

  val of_int: int -> t
  val to_int: t -> int
end

module DiagnosticTag : sig
  type t =
    | Unnecessary
    | Deprecated

  val of_int: int -> t
  val to_int: t -> int
end

module DiagnosticRelatedInformation : sig
  type t = {location: Location.t; message: string}
end

module CodeDescription : sig
  type t = {href: URI.t}
end

module Diagnostic : sig
  type t =
    { range: Range.t
    ; severity: DiagnosticSeverity.t option
    ; code: [`String of string |`Int of int] option
    ; codeDescription: CodeDescription.t option
    ; source: string option
    ; message: string
    ; tags: DiagnosticTag.t list option
    ; relatedInformations: DiagnosticRelatedInformation.t list option
    ; data: Jsonrpc.Message.t option}
end

module Command : sig
  type t = {title: string; command: string; arguments = [`List of Jsonrpc.Json.t list] option}
end

module TextEdit : sig
  type t = {range: Range.t; newText: string}
end

module ChangeAnnotation : sig
  type t = {label: string; needsConfirmation: bool option; description: string option}
end

module ChangeAnnotationIdentifier : sig
  type t = string
end

module AnnotatedTextEdit : sig
  type t = {annotationId : ChangeAnnotationIdentifier.t; textEdit: TextEdit.t}
end

module OptionnalVersionnedTextDocumentIdentifier : sig
  type t
end

module TextDocumentEdit : sig
  type edit =
    | TextEdit of TextEdit.t
    | AnnotatedTextEdit of AnnotatedTextEdit.t

  type t = {textDocument: OptionnalVersionnedTextDocumentIdentifier.t; edits: edit list option}
end

module CreateFileOption : sig
  type t = {overwrite: bool option; ignoreIfExists: bool option}
end

module CreateFile : sig
  type t = { kind: string; uri: DocumentUri.t; options: CreateFileOption.t option; annotationId: ChangeAnnotationIdentifier.t }
end

module RenameFileOption : sig
  type t = {overwrite: bool option; ignoreIfExists: bool option}
end

module RenameFile : sig
  type t = { kind: string; odlUri: DocumentUri.t; newUri: DocumentUri.t; options: RenameFileOption option; annotationId: ChangeAnnotationIdentifier option }
end

module DeleteFileOptions : sig
  type t = {recursive: bool option; ignoreIfNotExists: bool option}
end

module DeleteFile : sig
  type t = {kind: string; uri: DocumentUri.t; options: DeleteFileOptions option; annotationId: ChangeAnnotationIdentifier option}
end
