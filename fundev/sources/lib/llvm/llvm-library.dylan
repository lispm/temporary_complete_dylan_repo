Module:       Dylan-User
Author:       Peter S. Housel
Copyright:    Original Code is Copyright 2009-2010 Gwydion Dylan Maintainers
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library llvm
  use dylan;
  use common-dylan;
  use collections;
  use io;
  use system;
  use generic-arithmetic;
  use big-integers;

  export llvm;
  export llvm-builder;
  export llvm-debug;
end library;

define module llvm
  create
    <llvm-type>,
    <llvm-primitive-type>,
    <llvm-integer-type>,
    llvm-integer-type-width,
    <llvm-pointer-type>,
    llvm-pointer-type-pointee,
    <llvm-function-type>,
    llvm-function-type-return-type,
    llvm-function-type-parameter-types,
    llvm-function-type-varargs?,
    <llvm-struct-type>,
    llvm-struct-type-elements,
    <llvm-union-type>,
    <llvm-array-type>,
    <llvm-vector-type>,

    <llvm-placeholder-type>,
    llvm-placeholder-type-forward-setter,
    llvm-type-forward,

    llvm-constrain-type,

    <llvm-upval-type>,
    llvm-type-resolve-upvals,

    <llvm-opaque-type>,

    <llvm-symbolic-type>,

    llvm-void-type?,

    $llvm-label-type,
    $llvm-void-type,
    $llvm-metadata-type,
    $llvm-float-type,
    $llvm-double-type,
    $llvm-i1-type,
    $llvm-i8-type,
    $llvm-i8*-type,
    $llvm-i16-type,
    $llvm-i32-type,
    $llvm-i64-type,

    <llvm-value>,
    llvm-value-type,

    <llvm-placeholder-value>,
    llvm-placeholder-value-forward-setter,
    llvm-value-forward,

    <llvm-symbolic-value>,
    <llvm-symbolic-constant>,

    <llvm-constant-value>,
    <llvm-null-constant>,
    <llvm-undef-constant>,
    <llvm-integer-constant>,
    <llvm-float-constant>,
    <llvm-aggregate-constant>,
    <llvm-asm-constant>,
    <llvm-binop-constant>,
    <llvm-cast-constant>,
    <llvm-gep-constant>,
    <llvm-icmp-constant>,
    <llvm-fcmp-constant>,

    $llvm-false,
    $llvm-true,

    <llvm-metadata-value>,
    <llvm-metadata-string>,
    llvm-metadata-string,
    <llvm-metadata-node>,
    llvm-metadata-node-values,
    <llvm-symbolic-metadata>,

    <llvm-named-metadata>,
    llvm-named-metadata-name,
    llvm-named-metadata-operands,

    <llvm-global-value>,
    llvm-global-name,
    <llvm-global-variable>,
    <llvm-global-alias>,

    <llvm-attributes>,
    $llvm-attribute-none,
    $llvm-attribute-zext,
    $llvm-attribute-sext,
    $llvm-attribute-noreturn,
    $llvm-attribute-inreg,
    $llvm-attribute-sret,
    $llvm-attribute-nounwind,
    $llvm-attribute-noalias,
    $llvm-attribute-byval,
    $llvm-attribute-nest,
    $llvm-attribute-readnone,
    $llvm-attribute-readonly,
    $llvm-attribute-noinline,
    $llvm-attribute-alwaysinline,
    $llvm-attribute-optsize,
    $llvm-attribute-ssp,
    $llvm-attribute-sspreq,
    llvm-attribute-alignment,
    $llvm-attribute-nocapture,
    $llvm-attribute-noredzone,
    $llvm-attribute-noimplicitfloat,
    $llvm-attribute-naked,
    $llvm-attribute-inlinehint,
    llvm-attribute-stack-alignment,
    llvm-attribute-merge,
    <llvm-attribute-list>,

    $llvm-calling-convention-c,
    $llvm-calling-convention-fast,
    $llvm-calling-convention-cold,
    $llvm-calling-convention-ghc,
    $llvm-calling-convention-x86-stdcall,
    $llvm-calling-convention-x86-fastcall,
    $llvm-calling-convention-arm-apcs,
    $llvm-calling-convention-arm-aapcs,
    $llvm-calling-convention-arm-vfp,
    $llvm-calling-convention-msp430-intr,
    $llvm-calling-convention-x86-thiscall,
    $llvm-calling-convention-ptx-kernel,
    $llvm-calling-convention-ptx-device,
    
    <llvm-function>,
    llvm-function-arguments,
    llvm-function-basic-blocks,
    llvm-function-value-table,
    llvm-function-calling-convention,
    llvm-function-attribute-list,

    <llvm-argument>,
    llvm-argument-name,
    llvm-argument-attributes,
    llvm-argument-index,

    <llvm-basic-block>,
    llvm-basic-block-instructions,

    <llvm-instruction>,
    <llvm-binop-instruction>,
    <llvm-cast-instruction>,
    <llvm-gep-instruction>,
    <llvm-select-instruction>,
    <llvm-extractelement-instruction>,
    <llvm-insertelement-instruction>,
    <llvm-shufflevector-instruction>,
    <llvm-cmp-instruction>,
    <llvm-icmp-instruction>,
    <llvm-fcmp-instruction>,
    <llvm-terminator-instruction>,
    <llvm-return-instruction>,
    <llvm-branch-instruction>,
    <llvm-switch-instruction>,
    <llvm-invoke-instruction>,
    <llvm-unwind-instruction>,
    <llvm-unreachable-instruction>,
    <llvm-indirect-branch-instruction>,
    <llvm-phi-node>,
    <llvm-alloca-instruction>,
    <llvm-load-instruction>,
    <llvm-store-instruction>,
    <llvm-call-instruction>,
    <llvm-va-arg-instruction>,
    <llvm-extract-value-instruction>,
    <llvm-insert-value-instruction>,
    
    <llvm-module>,
    llvm-module-name,
    llvm-module-target-triple,
    llvm-module-target-triple-setter,
    llvm-module-data-layout,
    llvm-module-data-layout-setter,
    llvm-module-asm,
    llvm-module-asm-setter,
    llvm-module-globals,
    llvm-module-functions,
    llvm-module-aliases,
    llvm-module-named-metadata,
    llvm-module-dependent-libraries,
    llvm-type-table,
    llvm-global-table,

    llvm-save-bitcode-file;
end module;

define module llvm-builder
  create
    <llvm-builder>,
    llvm-builder-module,
    llvm-builder-module-setter,
    llvm-builder-function,
    llvm-builder-function-setter,
    llvm-builder-basic-block,
    llvm-builder-basic-block-setter,
    llvm-builder-dbg,
    llvm-builder-dbg-setter,

    llvm-builder-value,
    llvm-builder-value-function,

    llvm-builder-define-global,
    llvm-builder-declare-global,
    llvm-builder-global,

    ins--local,
    llvm-builder-local,
    
    ins--block,

    ins--dbg,

    ins--add,
    ins--fadd,
    ins--sub,
    ins--fsub,
    ins--mul,
    ins--fmul,
    ins--udiv,
    ins--sdiv,
    ins--fdiv,
    ins--urem,
    ins--srem,
    ins--frem,
    ins--shl,
    ins--lshr,
    ins--ashr,
    ins--and,
    ins--or,
    ins--xor,

    ins--trunc,
    ins--zext,
    ins--sext,
    ins--fptoui,
    ins--fptosi,
    ins--uitofp,
    ins--sitofp,
    ins--fptrunc,
    ins--fpext,
    ins--ptrtoint,
    ins--inttoptr,
    ins--bitcast,

    ins--icmp-eq,
    ins--icmp-ne,
    ins--icmp-slt,
    ins--icmp-sgt,
    ins--icmp-sle,
    ins--icmp-sge,
    ins--icmp-ult,
    ins--icmp-ugt,
    ins--icmp-ule,
    ins--icmp-uge,

    ins--fcmp-oeq,
    ins--fcmp-one,
    ins--fcmp-olt,
    ins--fcmp-ogt,
    ins--fcmp-ole,
    ins--fcmp-oge,
    ins--fcmp-ord,
    ins--fcmp-uno,
    ins--fcmp-ueq,
    ins--fcmp-une,
    ins--fcmp-ult,
    ins--fcmp-ugt,
    ins--fcmp-ule,
    ins--fcmp-uge,
    ins--fcmp-true,
    ins--fcmp-false,

    ins--gep,
    ins--gep-inbounds,

    ins--select,
    ins--va-arg,

    ins--extractelement,
    ins--insertelement,
    ins--shufflevector,
    
    ins--phi,
    
    ins--call,
    ins--tail-call,
    ins--call-intrinsic,
    ins--alloca,
    ins--load,
    ins--store,
    
    ins--insertvalue,
    ins--extractvalue,
    
    ins--ret,
    ins--br,
    ins--switch,
    ins--invoke,
    ins--unwind,
    ins--unreachable;
end module;

define module llvm-debug
  create
    $llvm-debug-version,
    $DW-TAG-invalid,
    $DW-TAG-anchor,
    $DW-TAG-auto-variable,
    $DW-TAG-arg-variable,
    $DW-TAG-return-variable,
    $DW-TAG-vector-type,
    $DW-TAG-user-base,
    $DW-TAG-array-type,
    $DW-TAG-class-type,
    $DW-TAG-entry-point,
    $DW-TAG-enumeration-type,
    $DW-TAG-formal-parameter,
    $DW-TAG-imported-declaration,
    $DW-TAG-label,
    $DW-TAG-lexical-block,
    $DW-TAG-member,
    $DW-TAG-pointer-type,
    $DW-TAG-reference-type,
    $DW-TAG-compile-unit,
    $DW-TAG-string-type,
    $DW-TAG-structure-type,
    $DW-TAG-subroutine-type,
    $DW-TAG-typedef,
    $DW-TAG-union-type,
    $DW-TAG-unspecified-parameters,
    $DW-TAG-variant,
    $DW-TAG-common-block,
    $DW-TAG-common-inclusion,
    $DW-TAG-inheritance,
    $DW-TAG-inlined-subroutine,
    $DW-TAG-module,
    $DW-TAG-ptr-to-member-type,
    $DW-TAG-set-type,
    $DW-TAG-subrange-type,
    $DW-TAG-with-stmt,
    $DW-TAG-access-declaration,
    $DW-TAG-base-type,
    $DW-TAG-catch-block,
    $DW-TAG-const-type,
    $DW-TAG-constant,
    $DW-TAG-enumerator,
    $DW-TAG-file-type,
    $DW-TAG-friend,
    $DW-TAG-namelist,
    $DW-TAG-namelist-item,
    $DW-TAG-packed-type,
    $DW-TAG-subprogram,
    $DW-TAG-template-type-parameter,
    $DW-TAG-template-value-parameter,
    $DW-TAG-thrown-type,
    $DW-TAG-try-block,
    $DW-TAG-variant-part,
    $DW-TAG-variable,
    $DW-TAG-volatile-type,
    $DW-TAG-dwarf-procedure,
    $DW-TAG-restrict-type,
    $DW-TAG-interface-type,
    $DW-TAG-namespace,
    $DW-TAG-imported-module,
    $DW-TAG-unspecified-type,
    $DW-TAG-partial-unit,
    $DW-TAG-imported-unit,
    $DW-TAG-condition,
    $DW-TAG-shared-type,
    $DW-TAG-lo-user,
    $DW-TAG-hi-user,
    $DW-ATE-address,
    $DW-ATE-boolean,
    $DW-ATE-complex-float,
    $DW-ATE-float,
    $DW-ATE-signed,
    $DW-ATE-signed-char,
    $DW-ATE-unsigned,
    $DW-ATE-unsigned-char,
    $DW-ATE-imaginary-float,
    $DW-ATE-packed-decimal,
    $DW-ATE-numeric-string,
    $DW-ATE-edited,
    $DW-ATE-signed-fixed,
    $DW-ATE-unsigned-fixed,
    $DW-ATE-decimal-float,
    $DW-ATE-lo-user,
    $DW-ATE-hi-user,
    $DW-LANG-C89,
    $DW-LANG-C,
    $DW-LANG-Ada83,
    $DW-LANG-C-plus-plus,
    $DW-LANG-Cobol74,
    $DW-LANG-Cobol85,
    $DW-LANG-Fortran77,
    $DW-LANG-Fortran90,
    $DW-LANG-Pascal83,
    $DW-LANG-Modula2,
    $DW-LANG-Java,
    $DW-LANG-C99,
    $DW-LANG-Ada95,
    $DW-LANG-Fortran95,
    $DW-LANG-PLI,
    $DW-LANG-ObjC,
    $DW-LANG-ObjC-plus-plus,
    $DW-LANG-UPC,
    $DW-LANG-D,
    $DW-LANG-lo-user,
    $DW-LANG-Dylan,
    $DW-LANG-hi-user,

    llvm-make-dbg-compile-unit,
    llvm-make-dbg-file,
    llvm-make-dbg-function-type,
    llvm-make-dbg-function,
    llvm-make-dbg-lexical-block;
end module;

define module llvm-internals
  use dylan-extensions,
    import: { <double-integer>, %double-integer-low, %double-integer-high,
              decode-single-float, decode-double-float,
              encode-single-float, encode-double-float };
  use machine-word-lowlevel;
  use common-dylan, exclude: { format-to-string };
  use streams;
  use format;
  use file-system;
  use locators;
  use machine-words;
  use byte-vector;
  use operating-system;
  use threads;
  use big-integers,
    prefix: "generic-",
    rename: { <integer> => <abstract-integer> };

  use llvm,
    rename: { llvm-type-forward => type-forward,
              llvm-value-forward => value-forward };
  use llvm-builder;
  use llvm-debug;
end module;
