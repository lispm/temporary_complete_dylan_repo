Module:    carbon-interface
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// This file is automatically generated from "Aliases.h"; do not edit.

// unnamed enum:
define inline-only constant $rAliasType                = FOUR_CHAR_CODE('a', 'l', 'i', 's');

// unnamed enum:
define inline-only constant $kARMMountVol              = #x00000001;
define inline-only constant $kARMNoUI                  = #x00000002;
define inline-only constant $kARMMultVols              = #x00000008;
define inline-only constant $kARMSearch                = #x00000100;
define inline-only constant $kARMSearchMore            = #x00000200;
define inline-only constant $kARMSearchRelFirst        = #x00000400;

// unnamed enum:
define inline-only constant $asiZoneName               = -3;
define inline-only constant $asiServerName             = -2;
define inline-only constant $asiVolumeName             = -1;
define inline-only constant $asiAliasName              = 0;
define inline-only constant $asiParentName             = 1;

// unnamed enum:
define inline-only constant $kResolveAliasFileNoUI     = #x00000001;


define C-struct <AliasRecord>
  sealed inline-only slot userType-value :: <OSType>;
  sealed inline-only slot aliasSize-value :: <C-unsigned-short>;
  pack: 2;
  c-name: "struct AliasRecord";
end;
define C-pointer-type <AliasRecord*> => <AliasRecord>;
define C-pointer-type <AliasRecord**> => <AliasRecord*>;
define C-pointer-type <AliasPtr> => <AliasRecord>;
define C-pointer-type <AliasHandle> => <AliasPtr>;
define inline constant <AliasInfoType> = <C-short>;
define C-pointer-type <AliasInfoType*> => <AliasInfoType>;
define C-pointer-type <AliasInfoType**> => <AliasInfoType*>;

define inline-only C-function NewAlias
  parameter fromFile   :: <ConstFSSpecPtr>;
  parameter target     ::  /* const */ <FSSpec*>;
  parameter alias      :: <AliasHandle*>;
  result value :: <OSErr>;
  c-name: "NewAlias";
  c-modifiers: "pascal";
end;

define inline-only C-function NewAliasMinimal
  parameter target     ::  /* const */ <FSSpec*>;
  parameter alias      :: <AliasHandle*>;
  result value :: <OSErr>;
  c-name: "NewAliasMinimal";
  c-modifiers: "pascal";
end;

define inline-only C-function NewAliasMinimalFromFullPath
  parameter fullPathLength :: <C-short>;
  parameter fullPath   ::  /* const */ <C-void*>;
  parameter zoneName   :: <ConstStr32Param>;
  parameter serverName :: <ConstStr31Param>;
  parameter alias      :: <AliasHandle*>;
  result value :: <OSErr>;
  c-name: "NewAliasMinimalFromFullPath";
  c-modifiers: "pascal";
end;

define inline-only C-function ResolveAlias
  parameter fromFile   :: <ConstFSSpecPtr>;
  parameter alias      :: <AliasHandle>;
  parameter target     :: <FSSpec*>;
  parameter wasChanged :: <MacBoolean*>;
  result value :: <OSErr>;
  c-name: "ResolveAlias";
  c-modifiers: "pascal";
end;

define inline-only C-function GetAliasInfo
  parameter alias      :: <AliasHandle>;
  parameter index      :: <AliasInfoType>;
  parameter theString  :: <Str63>;
  result value :: <OSErr>;
  c-name: "GetAliasInfo";
  c-modifiers: "pascal";
end;

define inline-only C-function IsAliasFile
  parameter fileFSSpec ::  /* const */ <FSSpec*>;
  parameter aliasFileFlag :: <MacBoolean*>;
  parameter folderFlag :: <MacBoolean*>;
  result value :: <OSErr>;
  c-name: "IsAliasFile";
  c-modifiers: "pascal";
end;

define inline-only C-function ResolveAliasWithMountFlags
  parameter fromFile   ::  /* const */ <FSSpec*>;
  parameter alias      :: <AliasHandle>;
  parameter target     :: <FSSpec*>;
  parameter wasChanged :: <MacBoolean*>;
  parameter mountFlags :: <C-both-unsigned-long>;
  result value :: <OSErr>;
  c-name: "ResolveAliasWithMountFlags";
  c-modifiers: "pascal";
end;

define inline-only C-function ResolveAliasFile
  parameter theSpec    :: <FSSpec*>;
  parameter resolveAliasChains :: <MacBoolean>;
  parameter targetIsFolder :: <MacBoolean*>;
  parameter wasAliased :: <MacBoolean*>;
  result value :: <OSErr>;
  c-name: "ResolveAliasFile";
  c-modifiers: "pascal";
end;

define inline-only C-function ResolveAliasFileWithMountFlags
  parameter theSpec    :: <FSSpec*>;
  parameter resolveAliasChains :: <MacBoolean>;
  parameter targetIsFolder :: <MacBoolean*>;
  parameter wasAliased :: <MacBoolean*>;
  parameter mountFlags :: <C-both-unsigned-long>;
  result value :: <OSErr>;
  c-name: "ResolveAliasFileWithMountFlags";
  c-modifiers: "pascal";
end;

define inline-only C-function FollowFinderAlias
  parameter fromFile   :: <ConstFSSpecPtr>;
  parameter alias      :: <AliasHandle>;
  parameter logon      :: <MacBoolean>;
  parameter target     :: <FSSpec*>;
  parameter wasChanged :: <MacBoolean*>;
  result value :: <OSErr>;
  c-name: "FollowFinderAlias";
  c-modifiers: "pascal";
end;

define inline-only C-function UpdateAlias
  parameter fromFile   :: <ConstFSSpecPtr>;
  parameter target     ::  /* const */ <FSSpec*>;
  parameter alias      :: <AliasHandle>;
  parameter wasChanged :: <MacBoolean*>;
  result value :: <OSErr>;
  c-name: "UpdateAlias";
  c-modifiers: "pascal";
end;
define constant <AliasFilterProcPtr> = <C-function-pointer>;
define constant <AliasFilterUPP> = <UniversalProcPtr>;
// unnamed enum:
define inline-only constant $uppAliasFilterProcInfo    = #x00000FD0;


define inline-only C-function MatchAlias
  parameter fromFile   :: <ConstFSSpecPtr>;
  parameter rulesMask  :: <C-both-unsigned-long>;
  parameter alias      :: <AliasHandle>;
  parameter aliasCount :: <C-short*>;
  parameter aliasList  :: <FSSpecArrayPtr>;
  parameter needsUpdate :: <MacBoolean*>;
  parameter aliasFilter :: <AliasFilterUPP>;
  parameter yourDataPtr :: <C-void*>;
  result value :: <OSErr>;
  c-name: "MatchAlias";
  c-modifiers: "pascal";
end;
