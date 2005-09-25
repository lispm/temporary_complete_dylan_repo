
! Use these patterns to convert "winerror.h" for use as "com-err.dylan".
! Extracts the error codes pertaining to COM and emits corresponding
! Dylan definitions for them.

! Copyright: 1996, 1998 Functional Objects, Inc.  All rights reserved.
! Version:   $HopeName$
!	     $Date: 2004/03/12 00:09:31 $

@set-switch{match;1}

\B=Module\:    COM\n@copyright{\:}\n\
  \n\/\/ This file is automatically generated from @file\; do not edit.\n\n

\N\#define <error-name> <number>\W\n=\
	define inline-only constant @export{\$$1} @tab{38}\=\
	@wrap{\ as(<machine-word>, $2)}\;\n

! Preserve message text comments because some of these error codes are not
! documented anywhere other than in the header file.
\/\/\L MessageId\: <error-name>\G\W\n\/\/\n\/\/ MessageText\:\n\
	<message-text>\G\P\#define $1=\n$2

message-text:\/\/\W\n=
message-text:\/\/\W*\n=\/\/ *\n
message-text:=@terminate

error-name:E_<id>=$0@end
error-name:CO_E_<id>=$0@end
error-name:MK_E_<id>=$0@end
error-name:STG_E_<id>=$0@end
error-name:RPC_E_<id>=$0@end
error-name:REGDB_E_<id>=$0@end
error-name:CLASS_E_<id>=$0@end
error-name:=@fail

id:FIRST\I=@fail
id:LAST\I=@fail
id:<I>=$1@end

\N\#define <success-name> <number>\W\n=\
	define inline-only constant @export{\$$1} @tab{38}\=\
	@wrap{\ as(<machine-word>, $2)}\;\n

success-name:S_<I>=$0@end
success-name:MK_S_<id>=$0@end
success-name:STG_S_<id>=$0@end
success-name:RPC_S_<id>=$0@end
success-name:OLE_=@fail
success-name:=@fail

number:(<number>)=$1@end
number:0x<X><optL>=\#x$1@end
!number:0<O><optL>=\#o$1@end
!number:<D><optL>=$1@end
number:<D>=@fail
number:_HRESULT_TYPEDEF_\W(<number>)=$1@end
number:(HRESULT)\W=
number:=@fail
optL:\CL=@end;=@end

\/\*<comment>\*\/=
comment:\/\*<comment>\*\/=
\/\/*\n=

\N\#define FACILITY_<I> <D>\W\n=\
 define inline-only constant @export{\$FACILITY_$1} @tab{51}\= @right{2;$2}\;\n

\N\#ifdef WIN32\W\n*\#<elsepart>=@{*}
\N\#ifdef _WIN32\W\n*\#<elsepart>=@{*}
\N\#if defined(_WIN32) \&\& \!defined(_MAC)\W\n*\#<elsepart>=@{*}
elsepart:endif=@end
elsepart:else *\#endif=@end
elsepart:=@fail