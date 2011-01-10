Module: scepter-tests
Author: Jason Trenouth
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define test corba-core-idl-CORBA ()
  check("", test-idl-file, *corba-core-files*, "CORBA");
end test;

add-idl-file!(
  *corba-core-files*,
  "CORBA",
"\n"
"\n"
"\n"
"// This file contains OMG IDL from  CORBA V2.0, July 1995. \n"
"// Includes IDL for CORBA Core\n"
"// (Interface Repository, ORB Interface, Basic Object Adapter Interface)\n"
"// and CORBA Interoperability (IOP, GIOP, IIOP, and DCE CIOP modules)\n"
"\n"
"// Complete OMG IDL for Interface Repository starts on pg 6-42, CORBA V2.0 July 1995\n"
"// IRObject interface described on pg 6-9 CORBA V2.0, July 1995\n"
"// Contained interface: pg 6-11 CORBA V2, 7-95\n"
"// Container interface: pg 6-12 thru 6-15 CORBA V2, 7-95\n"
"// IDLType interface: pg 6-15 CORBA V2, 7-95\n"
"// Repository interface: pg 6-16 CORBA V2, 7-95\n"
"// ModuleDef interface: pg 6-17 CORBA V2, 7-95\n"
"// ConstantDef interface: pg 6-18 CORBA V2, 7-95\n"
"// TypeDef interface: pg 6-19 CORBA V2, 7-95\n"
"// StructDef interface: pg 6-19 CORBA V2, 7-95\n"
"// UnionDef interface: pg 6-19 CORBA V2, 7-95\n"
"// EnumDef interface: pg 6-20 CORBA V2, 7-95\n"
"// AliasDef interface: pg 6-21 CORBA V2, 7-95\n"
"// PrimitiveDef interface: pg 6-21 CORBA V2, 7-95\n"
"// StringDef interface: pg 6-22 CORBA V2, 7-95\n"
"// SequenceDef interface: pg 6-22 CORBA V2, 7-95\n"
"// ArrayDef interface: pg 6-23 CORBA V2, 7-95\n"
"// ExceptionDef interface: pg 6-24 CORBA V2, 7-95\n"
"// AttributeDef interface: pg 6-25 CORBA V2, 7-95\n"
"// OperationDef interface: pg 6-26 CORBA V2, 7-95\n"
"// InterfaceDef interface: pg 6-28 CORBA V2, 7-95\n"
"// TypeCode interface (PIDL): pg 6-34 CORBA V2, 7-95\n"
"// ORB interface: pg 6-40 CORBA V2, 7-95 \n"
"\n"
"#pragma prefix \"omg.org\"\n"
"module CORBA {\n"
"    typedef string Identifier;\n"
"    typedef string ScopedName;\n"
"    typedef string RepositoryId;\n"
"\n"
"    enum DefinitionKind {\n"
"\tdk_none, dk_all,\n"
"\tdk_Attribute, dk_Constant, dk_Exception, dk_Interface,\n"
"\tdk_Module, dk_Operation, dk_Typedef,\n"
"\tdk_Alias, dk_Struct, dk_Union, dk_Enum,\n"
"\tdk_Primitive, dk_String, dk_Sequence, dk_Array,\n"
"\tdk_Repository\n"
"    };\n"
"\n"
"\n"
"    interface IRObject {\n"
"\t// read interface\n"
"\treadonly attribute DefinitionKind def_kind;\n"
"\n"
"\t// write interface\n"
"\tvoid destroy ();\n"
"    };\n"
"\n"
"\n"
"\n"
"    typedef string VersionSpec;\n"
"\n"
"    interface Contained;\n"
"    interface Repository;\n"
"    interface Container;\n"
"\n"
"    interface Contained : IRObject {\n"
"\t// read/write interface\n"
"\n"
"\tattribute RepositoryId id;\n"
"\tattribute Identifier name;\n"
"\tattribute VersionSpec version;\n"
"\n"
"\t// read interface\n"
"\n"
"\treadonly attribute Container defined_in;\n"
"\treadonly attribute ScopedName absolute_name;\n"
"\treadonly attribute Repository containing_repository;\n"
"\n"
"\tstruct Description {\n"
"\t    DefinitionKind kind;\n"
"\t    any value; \n"
"\t}; \n"
"\n"
"\tDescription describe ();\n"
"\n"
"\t// write interface\n"
"\n"
"\tvoid move (\n"
"\t    in Container new_container,\n"
"\t    in Identifier new_name,\n"
"\t    in VersionSpec new_version\n"
"\t    );\n"
"    };\n"
"\n"
"\n"
"    interface ModuleDef;\n"
"    interface ConstantDef;\n"
"    interface IDLType;\n"
"    interface StructDef;\n"
"    interface UnionDef;\n"
"    interface EnumDef;\n"
"    interface AliasDef;\n"
"    interface InterfaceDef;\n"
"    interface TypeCode;\n"
"    typedef sequence <InterfaceDef> InterfaceDefSeq;\n"
"\n"
"    typedef sequence <Contained> ContainedSeq;\n"
"\n"
"    struct StructMember {\n"
"\tIdentifier name;\n"
"\tTypeCode type;\n"
"\tIDLType type_def;\n"
"    };\n"
"    typedef sequence <StructMember> StructMemberSeq;\n"
"\n"
"    struct UnionMember {\n"
"\tIdentifier name;\n"
"\tany label;\n"
"\tTypeCode type;\n"
"\tIDLType type_def;\n"
"    };\n"
"    typedef sequence <UnionMember> UnionMemberSeq;\n"
"\n"
"    typedef sequence <Identifier> EnumMemberSeq;\n"
"\n"
"    interface Container : IRObject {\n"
"\t// read interface\n"
"\n"
"\tContained lookup ( in ScopedName search_name);\n"
"\n"
"\tContainedSeq contents (\n"
"\t    in DefinitionKind limit_type,\n"
"\t    in boolean exclude_inherited\n"
"\t    );\n"
"\n"
"\tContainedSeq lookup_name (\n"
"\t    in Identifier search_name, \n"
"\t    in long levels_to_search, \n"
"\t    in DefinitionKind limit_type,\n"
"\t    in boolean exclude_inherited\n"
"\t    );\n"
"\n"
"\tstruct Description {\n"
"\t    Contained contained_object; \n"
"\t    DefinitionKind kind;\n"
"\t    any value; \n"
"\t};\n"
"\n"
"\ttypedef sequence<Description> DescriptionSeq;\n"
"\n"
"\tDescriptionSeq describe_contents (\n"
"\t    in DefinitionKind limit_type,\n"
"\t    in boolean exclude_inherited,\n"
"\t    in long max_returned_objs\n"
"\t    );\n"
"\n"
"\t// write interface\n"
" \n"
"\tModuleDef create_module (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version\n"
"\t    );\n"
" \n"
"\tConstantDef create_constant (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in IDLType type,\n"
"\t    in any value\n"
"\t    );\n"
" \n"
"\tStructDef create_struct (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in StructMemberSeq members\n"
"\t    );\n"
" \n"
"\tUnionDef create_union (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in IDLType discriminator_type,\n"
"\t    in UnionMemberSeq members\n"
"\t    );\n"
" \n"
"\tEnumDef create_enum (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in EnumMemberSeq members\n"
"\t    );\n"
" \n"
"\tAliasDef create_alias (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in IDLType original_type\n"
"\t    );\n"
" \n"
"\tInterfaceDef create_interface (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in InterfaceDefSeq base_interfaces\n"
"\t    );\n"
"    };\n"
"\n"
"\n"
"\n"
"    interface IDLType : IRObject {\n"
"\treadonly attribute TypeCode type;\n"
"    };\n"
"\n"
"\n"
"\n"
"    interface PrimitiveDef;\n"
"    interface StringDef;\n"
"    interface SequenceDef;\n"
"    interface ArrayDef;\n"
"\n"
"    enum PrimitiveKind {\n"
"\tpk_null, pk_void, pk_short, pk_long, pk_ushort, pk_ulong,\n"
"\tpk_float, pk_double, pk_boolean, pk_char, pk_octet,\n"
"\tpk_any, pk_TypeCode, pk_Principal, pk_string, pk_objref\n"
"    };\n"
"\n"
"    interface Repository : Container {\n"
"\t// read interface\n"
"\n"
"\tContained lookup_id (in RepositoryId search_id);\n"
"\n"
"\tPrimitiveDef get_primitive (in PrimitiveKind kind);\n"
"\n"
"\t// write interface\n"
"\n"
"\tStringDef create_string (in unsigned long bound);\n"
"\n"
"\tSequenceDef create_sequence (\n"
"\t    in unsigned long bound,\n"
"\t    in IDLType element_type\n"
"\t    );\n"
"\n"
"\tArrayDef create_array (\n"
"\t    in unsigned long length,\n"
"\t    in IDLType element_type\n"
"\t    );\n"
"    };\n"
"\n"
"\n"
"    interface ModuleDef : Container, Contained {\n"
"    };\n"
"\n"
"    struct ModuleDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in;\n"
"\tVersionSpec version;\n"
"    };\n"
"\n"
"\n"
"    interface ConstantDef : Contained {\n"
"\treadonly attribute TypeCode type;\n"
"\tattribute IDLType type_def;\n"
"\tattribute any value;\n"
"    };\n"
"\n"
"    struct ConstantDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tTypeCode type; \n"
"\tany value; \n"
"    };\n"
"\n"
"\n"
"    interface TypedefDef : Contained, IDLType {\n"
"    };\n"
"\n"
"    struct TypeDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tTypeCode type; \n"
"    };\n"
"\n"
"\n"
"    interface StructDef : TypedefDef {\n"
"\tattribute StructMemberSeq members;\n"
"    };\n"
"\n"
"\n"
"    interface UnionDef : TypedefDef {\n"
"\treadonly attribute TypeCode discriminator_type;\n"
"\tattribute IDLType discriminator_type_def;\n"
"\tattribute UnionMemberSeq members;\n"
"    };\n"
"\n"
"\n"
"    interface EnumDef : TypedefDef {\n"
"\tattribute EnumMemberSeq members;\n"
"    };\n"
"\n"
"\n"
"    interface AliasDef : TypedefDef {\n"
"\tattribute IDLType original_type_def;\n"
"    };\n"
"\n"
"\n"
"    interface PrimitiveDef: IDLType {\n"
"\treadonly attribute PrimitiveKind kind;\n"
"    };\n"
"\n"
"\n"
"    interface StringDef : IDLType {\n"
"\tattribute unsigned long bound;\n"
"    };\n"
"\n"
"\n"
"    interface SequenceDef : IDLType {\n"
"\tattribute unsigned long bound;\n"
"\treadonly attribute TypeCode element_type;\n"
"\tattribute IDLType element_type_def;\n"
"    };\n"
"\n"
"    interface ArrayDef : IDLType {\n"
"\tattribute unsigned long length;\n"
"\treadonly attribute TypeCode element_type;\n"
"\tattribute IDLType element_type_def;\n"
"    };\n"
"\n"
"\n"
"    interface ExceptionDef : Contained {\n"
"\treadonly attribute TypeCode type;\n"
"\tattribute StructMemberSeq members;\n"
"    };\n"
"    struct ExceptionDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tTypeCode type; \n"
"    };\n"
"\n"
"\n"
"\n"
"    enum AttributeMode {ATTR_NORMAL, ATTR_READONLY};\n"
"\n"
"    interface AttributeDef : Contained {\n"
"\treadonly attribute TypeCode type;\n"
"\tattribute IDLType type_def;\n"
"\tattribute AttributeMode mode;\n"
"    };\n"
"\n"
"    struct AttributeDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tTypeCode type;\n"
"\tAttributeMode mode; \n"
"    };\n"
"\n"
"\n"
"\n"
"    enum OperationMode {OP_NORMAL, OP_ONEWAY};\n"
"\n"
"    enum ParameterMode {PARAM_IN, PARAM_OUT, PARAM_INOUT};\n"
"    struct ParameterDescription {\n"
"\tIdentifier name; \n"
"\tTypeCode type; \n"
"\tIDLType type_def;\n"
"\tParameterMode mode;\n"
"    };\n"
"    typedef sequence <ParameterDescription> ParDescriptionSeq;\n"
"\n"
"    typedef Identifier ContextIdentifier;\n"
"    typedef sequence <ContextIdentifier> ContextIdSeq;\n"
"\n"
"    typedef sequence <ExceptionDef> ExceptionDefSeq;\n"
"    typedef sequence <ExceptionDescription> ExcDescriptionSeq;\n"
"\n"
"    interface OperationDef : Contained { \n"
"\treadonly attribute TypeCode result;\n"
"\tattribute IDLType result_def;\n"
"\tattribute ParDescriptionSeq params;\n"
"\tattribute OperationMode mode; \n"
"\tattribute ContextIdSeq contexts;\n"
"\tattribute ExceptionDefSeq exceptions;\n"
"    };\n"
"\n"
"    struct OperationDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tTypeCode result; \n"
"\tOperationMode mode; \n"
"\tContextIdSeq contexts; \n"
"\tParDescriptionSeq parameters;\n"
"\tExcDescriptionSeq exceptions;\n"
"    };\n"
"\n"
"\n"
"\n"
"    typedef sequence <RepositoryId> RepositoryIdSeq;\n"
"    typedef sequence <OperationDescription> OpDescriptionSeq;\n"
"    typedef sequence <AttributeDescription> AttrDescriptionSeq;\n"
"\n"
"    interface InterfaceDef : Container, Contained, IDLType {\n"
"\t// read/write interface\n"
"\n"
"\tattribute InterfaceDefSeq base_interfaces;\n"
"\n"
"\t// read interface\n"
"\n"
"\tboolean is_a (in RepositoryId interface_id);\n"
"\n"
"\tstruct FullInterfaceDescription {\n"
"\t    Identifier name;\n"
"\t    RepositoryId id;\n"
"\t    RepositoryId defined_in;\n"
"\t    VersionSpec version;\n"
"\t    OpDescriptionSeq operations;\n"
"\t    AttrDescriptionSeq attributes;\n"
"\t    RepositoryIdSeq base_interfaces;\n"
"\t    TypeCode type;\n"
"\t};\n"
"\n"
"\tFullInterfaceDescription describe_interface();\n"
"\n"
"\t// write interface\n"
"\n"
"\tAttributeDef create_attribute (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in IDLType type,\n"
"\t    in AttributeMode mode\n"
"\t    );\n"
"\n"
"\tOperationDef create_operation (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in VersionSpec version,\n"
"\t    in IDLType result,\n"
"\t    in OperationMode mode, \n"
"\t    in ParDescriptionSeq params,\n"
"\t    in ExceptionDefSeq exceptions,\n"
"\t    in ContextIdSeq contexts\n"
"\t    );\n"
"    };\n"
"\n"
"    struct InterfaceDescription {\n"
"\tIdentifier name; \n"
"\tRepositoryId id; \n"
"\tRepositoryId defined_in; \n"
"\tVersionSpec version;\n"
"\tRepositoryIdSeq base_interfaces;\n"
"    };\n"
"\n"
"\n"
"\n"
"    enum TCKind { \n"
"\ttk_null, tk_void, \n"
"\ttk_short, tk_long, tk_ushort, tk_ulong, \n"
"\ttk_float, tk_double, tk_boolean, tk_char, \n"
"\ttk_octet, tk_any, tk_TypeCode, tk_Principal, tk_objref, \n"
"\ttk_struct, tk_union, tk_enum, tk_string, \n"
"\ttk_sequence, tk_array, tk_alias, tk_except\n"
"    };\n"
"\n"
"    interface TypeCode { // PIDL\n"
"\texception Bounds {};\n"
"\texception BadKind {};\n"
"\n"
"\t// for all TypeCode kinds\n"
"\tboolean equal (in TypeCode tc);\n"
"\tTCKind kind ();\n"
"\n"
"\t// for tk_objref, tk_struct, tk_union, tk_enum, tk_alias, and tk_except\n"
"\tRepositoryId id () raises (BadKind);\n"
"\n"
"\t// for tk_objref, tk_struct, tk_union, tk_enum, tk_alias, and tk_except\n"
"\tIdentifier name () raises (BadKind);\n"
"\n"
"\t// for tk_struct, tk_union, tk_enum, and tk_except\n"
"\tunsigned long member_count () raises (BadKind);\n"
"\tIdentifier member_name (in unsigned long index) raises (BadKind, Bounds);\n"
"\n"
"\t// for tk_struct, tk_union, and tk_except\n"
"\tTypeCode member_type (in unsigned long index) raises (BadKind, Bounds);\n"
"\n"
"\t// for tk_union\n"
"\tany member_label (in unsigned long index) raises (BadKind, Bounds);\n"
"\tTypeCode discriminator_type () raises (BadKind);\n"
"\tlong default_index () raises (BadKind); \n"
"\n"
"\t// for tk_string, tk_sequence, and tk_array\n"
"\tunsigned long length () raises (BadKind);\n"
"\n"
"\t// for tk_sequence, tk_array, and tk_alias\n"
"\tTypeCode content_type () raises (BadKind);\n"
"\n"
"\t// deprecated interface\n"
"\tlong param_count (); \n"
"\tany parameter (in long index) raises (Bounds); \n"
"    };\n"
"\n"
"// Jason: conforming implementations can define Status in either of\n"
"// two ways. Choose natural version.\n"
"typedef unsigned long Status; \n"
"\n"
"// Jason: NamedValue and NVList seem to have go lost somewhere\n"
"typedef unsigned long Flags;\n"
"\n"
"struct NamedValue { \n"
"  Identifier name;\n"
"  any argument;\n"
"  long len;\n"
"  Flags arg_modes;\n"
"};\n"
"\n"
"typedef sequence<NamedValue> NVList;\n"
"\n"
"// Jason: These seem to have go lost somewhere\n"
"interface Context;\n"
"interface Request;\n"
"interface Environment;\n"
"\n"
"interface InterfaceDef;\t\t\t// from Interface Repository // PIDL\n"
"interface ImplementationDef;\t\t// from Implementation Repository\n"
"\n"
"interface Object {\n"
"\n"
"\tImplementationDef get_implementation ();\n"
"\tInterfaceDef get_interface ();\n"
"\tboolean is_nil();\n"
"\tObject duplicate ();\n"
"\tvoid release ();\n"
"\tboolean is_a (in string logical_type_id);\n"
"\tboolean non_existent();\n"
"\tboolean is_equivalent (in Object other_object);\n"
"\tunsigned long hash(in unsigned long maximum);\n"
"\n"
"\n"
"\tStatus create_request (\n"
"\t\tin Context ctx,\n"
"\t\tin Identifier  operation,\n"
"\t\tin NVList arg_list,\n"
"\t\tinout NamedValue result,\n"
"\t\tout Request request,\n"
"\t\tin Flags req_flags\n"
"\t);\n"
"};\n"
"\n"
"\n"
"// Basic Object Adapter interface described in Chapter 8, CORBA V2.0, July 1995\n"
"interface Object;  \t\t\t\t\t\t\t\t\t// an object reference\n"
"interface Principal;\t\t\t\t\t\t\t\t\t// for the authentication service\n"
"typedef sequence <octet, 1024> ReferenceData;\n"
"\n"
"interface BOA {\n"
"\tObject create (\n"
"\t\tin ReferenceData \t\t\t\t\t\t\tid, \n"
"\t\tin InterfaceDef \t\t\t\t\t\t\tintf,\n"
"\t\tin ImplementationDef \t\t\t\t\t\t\timpl\n"
"\t);\n"
"\tvoid dispose (in Object obj);\n"
"\tReferenceData get_id (in Object obj);\n"
"\n"
"\tvoid change_implementation (\n"
"\t\tin Object \t\t\t\t\t\t\tobj,\n"
"\t\tin ImplementationDef \t\t\t\t\t\t\timpl\n"
"\t\t);\n"
"\n"
"\tPrincipal get_principal (\n"
"\t\tin Object \t\t\t\t\t\t\tobj, \n"
"\t\tin Environment \t\t\t\t\t\t\tev\n"
"\t);\n"
"\n"
"        enum exception_type {NO, USER, SYSTEM_EXCEPTION };\n"
"\tvoid set_exception (\n"
"\t\tin exception_type \t\t\t\t\t\t\tmajor, // NO, USER,\n"
"\t\t\t\t\t\t\t\t\t\t\t// or SYSTEM_EXCEPTION\n"
"\t\tin string \t\t\t\t\t\t\tuserid,\t\t\t// exception type id\n"
"                // Jason: change void* to any\n"
"\t\tin any \t\t\t\t\t\t\tparam\t\t\t// pointer to associated data\n"
"\t);\n"
"\n"
"\tvoid impl_is_ready (in ImplementationDef impl);\n"
"\tvoid deactivate_impl (in ImplementationDef impl);\n"
"\tvoid obj_is_ready (in Object obj, in ImplementationDef impl);\n"
"\tvoid deactivate_obj (in Object obj);\n"
"};\n"
"\n"
"// The ORB interface (PIDL) is described in Chapter 7, CORBA V2.0 July 1995\n"
"// Object interface (object reference operations): pg 7-3 CORBA V2, 7-95\n"
"// ORB initialization: pg 7-7 CORBA V2, 7-95\n"
"// Object Adapter and Basic Object Adapter initialization: pg 7-8 CORBA V2 7-95\n"
"// Getting initial references: pg 7-10 CORBA V2 7-95\n"
"//PIDL\n"
"interface\t\t ORB {\n"
"\t// other operations ...\n"
"\n"
"\tTypeCode create_struct_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in StructMemberSeq members\n"
"\t    );\n"
"\n"
"\tTypeCode create_union_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in TypeCode discriminator_type,\n"
"\t    in UnionMemberSeq members\n"
"\t    );\n"
"\n"
"\tTypeCode create_enum_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in EnumMemberSeq members\n"
"\t    );\n"
"\n"
"\tTypeCode create_alias_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in TypeCode original_type\n"
"\t    );\n"
"\n"
"\tTypeCode create_exception_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name,\n"
"\t    in StructMemberSeq members\n"
"\t    );\n"
"\n"
"\tTypeCode create_interface_tc (\n"
"\t    in RepositoryId id,\n"
"\t    in Identifier name\n"
"\t    );\n"
"\n"
"\tTypeCode create_string_tc (\n"
"\t    in unsigned long bound\n"
"\t    );\n"
"\n"
"\tTypeCode create_sequence_tc (\n"
"\t    in unsigned long bound,\n"
"\t    in TypeCode element_type\n"
"\t    );\n"
"\n"
"\tTypeCode create_recursive_sequence_tc (\n"
"\t    in unsigned long bound,\n"
"\t    in unsigned long offset\n"
"\t    );\n"
"\n"
"\tTypeCode create_array_tc (\n"
"\t    in unsigned long length,\n"
"\t    in TypeCode element_type\n"
"\t    );\n"
"\n"
"\tstring object_to_string (in Object obj);\n"
"\tObject\t \tstring_to_object (in string str);\n"
"\n"
"\tStatus \t\tcreate_list (\n"
"\t\tin long\t \t\t\t\tcount,\t \n"
"\t\tout NVList\t\t \t\t\tnew_list\n"
"\t);\n"
"\tStatus\t\t create_operation_list (\n"
"\t\tin OperationDef \t\t\t\t\toper, \n"
"\t\tout NVList \t\t\t\t\tnew_list\n"
"\t);\n"
"\tStatus get_default_context (\t\t\t\t\t\t\tout\t Context\t\t ctx);\n"
"\n"
"// Initializing the ORB\n"
" \ttypedef string ORBid;\n"
" \ttypedef sequence <string> arg_list;\n"
" \tORB ORB_init (inout arg_list argv, in ORBid orb_identifier);\n"
"\n"
"// Initializing an object adapter and the Basic Object Adapter \n"
"\ttypedef string OAid;\n"
"\n"
"// Template for OA initialization operations\n"
"// <OA> <OA>_init (inout arg_list argv, \n"
"// in OAid oa_identifier);\n"
"\n"
"BOA BOA_init (inout arg_list argv,\n"
"\t\tin OAid boa_identifier); \n"
"\n"
"\n"
"\n"
"// Getting initial object references \n"
"\ttypedef string ObjectId;\n"
"\ttypedef sequence <ObjectId> ObjectIdList; \n"
"\n"
"\texception InvalidName {}; \n"
"\n"
"\tObjectIdList list_initial_services (); \n"
"\n"
"\tObject resolve_initial_references (in ObjectId identifier)\n"
"\t\traises (InvalidName); \n"
"};\n"
"};\n"
"\n"
"\n"
"\n"
"\n");
