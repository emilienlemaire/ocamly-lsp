open Json_rpc

module ProgressToken : sig
  type t =
    | Int of int
    | String of string
end

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

module WorkspaceEdit : sig
  type changes = { uri: DocumentUri.t; edits: TextEdit.t list }
  type documentChanges =
    | TextDocumentEdit of TextDocumentEdit.t list
    | CreateFile of CreateFile.t list
    | RenameFile of RenameFile.t list
    | DeleteFile of DeleteFile.t list
  type changeAnnotations = {id: string; hangeAnnotation: ChangeAnnotation.t}

  type t = {changes: changes list option; documentChanges: documentChanges list option; changeAnnotations: changeAnnotations list option}
end

module TextDocumentIdentifier : sig
  type t = {uri: DocumentUri.t}
end

module TextDocumentItem : sig
  type t = {uri: DocumentUri.t; languageId: string; version: int; text: string}
end

module VersionedTextDocumentIdentifier : sig
  type t = {textDocumentIdentifier: TextDocumentIdentifier.t; version: int}
end

module OptionalVersionedTextDocumentIdentifier : sig
  type t = {textDocumentIdentifier: TextDocumentIdentifier.t; version: [`Int of int | `Null]}
end

module DocumentFilter : sig
  type t = {langauge: string option; scheme: string option; pattern: string option}
end

module DocumentSelector : sig
  type t = DocumentFilter.t list
end

module StaticRegistrationInterface : sig
  type t = {id: string option}
end

module TextDocumentRegistrationOption : sig
  type documentSelector_or_null =
    | DocumentSelector of DocumentSelector.t
    | Null

  type t = {documentSelector: documentSelector_or_null}
end

module MarkupKind : sig
  type t =
    | PlainText
    | Markdown

  val of_string: string -> t
  val to_string: t -> string
end

module MarkupContent : sig
  type t = {kind: MarkupKind.t; value: string}
end

module WorkDoneProgressBegin : sig
  type t = {kind: string; title: string; cancellable: bool option; message: string option; percentage: int option}
end

module WorkDoneProgresseReport : sig
  type t = {kind: string; cancellable: bool option; message: string option; percentage: int option}
end

module WorkDoneProgressEnd : sig
  type t = {kind: string; message: string option}
end

module TraceValue : sig
  type t =
    | Off
    | Message
    | Verbose

  val of_string: string -> t
  val to_string: t -> string
end
