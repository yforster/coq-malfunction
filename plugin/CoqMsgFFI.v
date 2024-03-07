Require Import MetaCoq.Utils.bytestring.
From Malfunction.Plugin Require Import Loader.
From Malfunction Require Import FFI.

MetaCoq Extract Constants [ 
  coq_msg_info => "Coq_metacoq_extraction_plugin__Coq_ffi.msg_info",
  coq_msg_notice => "Coq_metacoq_extraction_plugin__Coq_ffi.msg_notice",
  coq_msg_debug => "Coq_metacoq_extraction_plugin__Coq_ffi.msg_debug",
  coq_user_error => "Coq_metacoq_extraction_plugin__Coq_ffi.user_error" ]
Packages [ "coq_metacoq_extraction.plugin" ].
