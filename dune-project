(lang dune 2.8)
(name ocamly_lsp)

(license Apache2)

(generate_opam_files true)

(package
 (name json_rpc)
 (synopsis "Simple JSON-RPC library")
 (description "")
 (depends
   yojson))

(package
 (name ocamly_lsp)
 (synopsis "LSP Server for OcamlLex AcamlYacc")
 (description "")
 (depends
   json_rpc
   lsp))

