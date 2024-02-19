From Malfunction.Plugin Require Loader.

(** Primitive ints *)
MetaCoq Extract Constants [
  Coq.Numbers.Cyclic.Int63.PrimInt63.int erased,
  Coq.Numbers.Cyclic.Int63.PrimInt63.add => "Coq_metacoq_extraction_malfunction_ffi__Uint63.add",
  Coq.Numbers.Cyclic.Int63.PrimInt63.sub => "Coq_metacoq_extraction_malfunction_ffi__Uint63.sub", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.mul => "Coq_metacoq_extraction_malfunction_ffi__Uint63.mul", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.div => "Coq_metacoq_extraction_malfunction_ffi__Uint63.div", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.mod => "Coq_metacoq_extraction_malfunction_ffi__Uint63.rem", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.lsl => "Coq_metacoq_extraction_malfunction_ffi__Uint63.l_sl", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.lsr => "Coq_metacoq_extraction_malfunction_ffi__Uint63.l_sr", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.land => "Coq_metacoq_extraction_malfunction_ffi__Uint63.l_and",
  Coq.Numbers.Cyclic.Int63.PrimInt63.lxor => "Coq_metacoq_extraction_malfunction_ffi__Uint63.l_xor",
  Coq.Numbers.Cyclic.Int63.PrimInt63.lor => "Coq_metacoq_extraction_malfunction_ffi__Uint63.l_or",
  Coq.Numbers.Cyclic.Int63.PrimInt63.asr => "Coq_metacoq_extraction_malfunction_ffi__Uint63.a_sr",
  Coq.Numbers.Cyclic.Int63.PrimInt63.head0 => "Coq_metacoq_extraction_malfunction_ffi__Uint63.head0", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.tail0 => "Coq_metacoq_extraction_malfunction_ffi__Uint63.tail0", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.eqb => "Coq_metacoq_extraction_malfunction_ffi__Uint63.equal",
  Coq.Numbers.Cyclic.Int63.PrimInt63.compare => "Coq_metacoq_extraction_malfunction_ffi__Uint63.compare", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.compares => "Coq_metacoq_extraction_malfunction_ffi__Uint63.compares", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.addc => "Coq_metacoq_extraction_malfunction_ffi__Uint63.addc", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.addcarryc => "Coq_metacoq_extraction_malfunction_ffi__Uint63.addcarryc", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.subc => "Coq_metacoq_extraction_malfunction_ffi__Uint63.subc",
  Coq.Numbers.Cyclic.Int63.PrimInt63.subcarryc => "Coq_metacoq_extraction_malfunction_ffi__Uint63.subcarryc", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.mulc => "Coq_metacoq_extraction_malfunction_ffi__Uint63.mulc", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.divs => "Coq_metacoq_extraction_malfunction_ffi__Uint63.divs", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.mods => "Coq_metacoq_extraction_malfunction_ffi__Uint63.rems", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.diveucl_21 => "Coq_metacoq_extraction_malfunction_ffi__Uint63.div21", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.diveucl => "Coq_metacoq_extraction_malfunction_ffi__Uint63.diveucl", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.addmuldiv => "Coq_metacoq_extraction_malfunction_ffi__Uint63.addmuldiv", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.leb => "Coq_metacoq_extraction_malfunction_ffi__Uint63.le", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.ltb => "Coq_metacoq_extraction_malfunction_ffi__Uint63.lt", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.ltsb => "Coq_metacoq_extraction_malfunction_ffi__Uint63.lts", 
  Coq.Numbers.Cyclic.Int63.PrimInt63.lesb => "Coq_metacoq_extraction_malfunction_ffi__Uint63.les"
]
Packages [ "coq_metacoq_extraction_malfunction_ffi" ].
