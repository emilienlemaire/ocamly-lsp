module RegularExpressionClientCapabilities : sig
  type t = {engine: string; version: string option}
end

module ResourceOperationKind : sig
  type t =
    | Create
    | Rename
    | Delete

  val of_string: string -> t
  val to_string: t -> string
end

module FailureHandlingKind : sig
  type t =
    | Abort
    | Transactional
    | Undo
    | TextOnlyTransactional

  val of_string: string -> t
  val to_string: t -> string
end

module WorkspaceEditClientCapabilities : sig
  type changeAnnotationSupport = {
    groupsOnLabel: bool option
  }

  type t = { documentChanges: bool option
  ; resourceOperations: ResourceOperationsKind.t list option
  ; failureHandling: FailureHandlingKind.t list option
  ; normalizesLineEnding: bool option
  ; changeAnnotationSupport: changeAnnotationSupport option }
end

module MarkdownClientCapabilities : sig
  type t = {parser: string; version: string option}
end

module TextDocumentClientCapabilities : sig
  type t = { synchronization: TextDocumentSyncClientCapabilities.t option
  ; completion: CompletionClientCapabilities.t option
  ; hover: HoverClientCapabilities.t option
  ; signatureHelp: SignatureHelpClientCapabilities.t option
  ; declaration: DeclarationClientCapabilities.t option
  ; definition: DefinitionClientCapabilities.t option
  ; typeDefinition: TypeDefinitionClientCapabilities.t option
  ; implementation: ImplementationClientCapabilities.t option
  ; references: ReferenceClientCapabilities.t option
  ; documentHighlight: DocumentHighlightClientCapabilities.t option
  ; documentSymbol: DocumentSymbolClientCapabilities.t option
  ; codeAction: CodeActionClientCapabilities.t option
  ; codeLens: CodeLensClientCapabilities.t option
  ; documentLink: DocumentLinkClientCapabilities.t option
  ; colorProvider: DocumentColorProviderClientCapabilities.t option
  ; formatting: DocumentFormattingClientCapabilities.t option
  ; rangeFormatting: DocumentFormattingClientCapabilities.t option
  ; onTypeFormatting: DocumentOnTypeFormattingClientCapabilites.t option
  ; rename: RenameClientCapabilities.t option
  ; publishDiagnostics: PublishDiagnosticsClientCapabilitis.t option
  ; foldingRange: FoldingRangeClientCapabilities.t option
  ; selectionRange: SelectionRangeClientCapabilities.t option
  ; linkedEditingRange: LinkedEditingRangeClientCapabilities.t option
  ; callHierarchy: CallHierarchyClientCapabilities.t option
  ; semanticToken: SemanticTokenClientCapabilities.t option
  ; moniker: MonikerClientCapabilities.t option}
