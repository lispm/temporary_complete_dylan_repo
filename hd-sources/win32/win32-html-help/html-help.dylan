Module:    Win32-HTML-Help
Copyright: 1998 Harlequin Group plc.  All rights reserved.

define C-pointer-type <LPHH-INFOTYPE> => <HH-INFOTYPE>;

// This file is automatically generated from "htmlhelp.h"; do not edit.


// Adapted from:
/****************************************************************************
*                                                                           *
* HtmlHelp.h                                                                *
*                                                                           *
* 
*                                                                           *
****************************************************************************/
define constant $HH-DISPLAY-TOPIC                   = #x0000;
define constant $HH-HELP-FINDER                     = #x0000;
define constant $HH-DISPLAY-TOC                     = #x0001;
define constant $HH-DISPLAY-INDEX                   = #x0002;
define constant $HH-DISPLAY-SEARCH                  = #x0003;
define constant $HH-SET-WIN-TYPE                    = #x0004;
define constant $HH-GET-WIN-TYPE                    = #x0005;
define constant $HH-GET-WIN-HANDLE                  = #x0006;
define constant $HH-ENUM-INFO-TYPE                  = #x0007;
define constant $HH-SET-INFO-TYPE                   = #x0008;
define constant $HH-SYNC                            = #x0009;
define constant $HH-ADD-NAV-UI                      = #x000A;
define constant $HH-ADD-BUTTON                      = #x000B;
define constant $HH-GETBROWSER-APP                  = #x000C;
define constant $HH-KEYWORD-LOOKUP                  = #x000D;
define constant $HH-DISPLAY-TEXT-POPUP              = #x000E;
define constant $HH-HELP-CONTEXT                    = #x000F;
define constant $HH-TP-HELP-CONTEXTMENU             = #x0010;
define constant $HH-TP-HELP-WM-HELP                 = #x0011;
define constant $HH-CLOSE-ALL                       = #x0012;
define constant $HH-ALINK-LOOKUP                    = #x0013;
define constant $HH-GET-LAST-ERROR                  = #x0014;
define constant $HH-ENUM-CATEGORY                   = #x0015;
define constant $HH-ENUM-CATEGORY-IT                = #x0016;
define constant $HH-RESET-IT-FILTER                 = #x0017;
define constant $HH-SET-INCLUSIVE-FILTER            = #x0018;
define constant $HH-SET-EXCLUSIVE-FILTER            = #x0019;
define constant $HH-SET-GUID                        = #x001A;
define constant $HH-INTERNAL                        = #x00FF;
define constant $HHWIN-PROP-ONTOP                   = ash(1,1);
define constant $HHWIN-PROP-NOTITLEBAR              = ash(1,2);
define constant $HHWIN-PROP-NODEF-STYLES            = ash(1,3);
define constant $HHWIN-PROP-NODEF-EXSTYLES          = ash(1,4);
define constant $HHWIN-PROP-TRI-PANE                = ash(1,5);
define constant $HHWIN-PROP-NOTB-TEXT               = ash(1,6);
define constant $HHWIN-PROP-POST-QUIT               = ash(1,7);
define constant $HHWIN-PROP-AUTO-SYNC               = ash(1,8);
define constant $HHWIN-PROP-TRACKING                = ash(1,9);
define constant $HHWIN-PROP-TAB-SEARCH              = ash(1,10);
define constant $HHWIN-PROP-TAB-HISTORY             = ash(1,11);
define constant $HHWIN-PROP-TAB-BOOKMARKS           = ash(1,12);
define constant $HHWIN-PROP-CHANGE-TITLE            = ash(1,13);
define constant $HHWIN-PROP-NAV-ONLY-WIN            = ash(1,14);
define constant $HHWIN-PROP-NO-TOOLBAR              = ash(1,15);
define constant $HHWIN-PROP-MENU                    = ash(1,16);
define constant $HHWIN-PROP-TAB-ADVSEARCH           = ash(1,17);
define constant $HHWIN-PROP-USER-POS                = ash(1,18);
define constant $HHWIN-PARAM-PROPERTIES             = ash(1,1);
define constant $HHWIN-PARAM-STYLES                 = ash(1,2);
define constant $HHWIN-PARAM-EXSTYLES               = ash(1,3);
define constant $HHWIN-PARAM-RECT                   = ash(1,4);
define constant $HHWIN-PARAM-NAV-WIDTH              = ash(1,5);
define constant $HHWIN-PARAM-SHOWSTATE              = ash(1,6);
define constant $HHWIN-PARAM-INFOTYPES              = ash(1,7);
define constant $HHWIN-PARAM-TB-FLAGS               = ash(1,8);
define constant $HHWIN-PARAM-EXPANSION              = ash(1,9);
define constant $HHWIN-PARAM-TABPOS                 = ash(1,10);
define constant $HHWIN-PARAM-TABORDER               = ash(1,11);
define constant $HHWIN-PARAM-HISTORY-COUNT          = ash(1,12);
define constant $HHWIN-PARAM-CUR-TAB                = ash(1,13);
define constant $HHWIN-BUTTON-EXPAND                = ash(1,1);
define constant $HHWIN-BUTTON-BACK                  = ash(1,2);
define constant $HHWIN-BUTTON-FORWARD               = ash(1,3);
define constant $HHWIN-BUTTON-STOP                  = ash(1,4);
define constant $HHWIN-BUTTON-REFRESH               = ash(1,5);
define constant $HHWIN-BUTTON-HOME                  = ash(1,6);
define constant $HHWIN-BUTTON-BROWSE-FWD            = ash(1,7);
define constant $HHWIN-BUTTON-BROWSE-BCK            = ash(1,8);
define constant $HHWIN-BUTTON-NOTES                 = ash(1,9);
define constant $HHWIN-BUTTON-CONTENTS              = ash(1,10);
define constant $HHWIN-BUTTON-SYNC                  = ash(1,11);
define constant $HHWIN-BUTTON-OPTIONS               = ash(1,12);
define constant $HHWIN-BUTTON-PRINT                 = ash(1,13);
define constant $HHWIN-BUTTON-INDEX                 = ash(1,14);
define constant $HHWIN-BUTTON-SEARCH                = ash(1,15);
define constant $HHWIN-BUTTON-HISTORY               = ash(1,16);
define constant $HHWIN-BUTTON-BOOKMARKS             = ash(1,17);
define constant $HHWIN-BUTTON-JUMP1                 = ash(1,18);
define constant $HHWIN-BUTTON-JUMP2                 = ash(1,19);
define constant $HHWIN-BUTTON-ZOOM                  = ash(1,20);
define constant $HHWIN-BUTTON-TOC-NEXT              = ash(1,21);
define constant $HHWIN-BUTTON-TOC-PREV              = ash(1,22);
define constant $IDTB-EXPAND                        =  200;
define constant $IDTB-CONTRACT                      =  201;
define constant $IDTB-STOP                          =  202;
define constant $IDTB-REFRESH                       =  203;
define constant $IDTB-BACK                          =  204;
define constant $IDTB-HOME                          =  205;
define constant $IDTB-SYNC                          =  206;
define constant $IDTB-PRINT                         =  207;
define constant $IDTB-OPTIONS                       =  208;
define constant $IDTB-FORWARD                       =  209;
define constant $IDTB-NOTES                         =  210;
define constant $IDTB-BROWSE-FWD                    =  211;
define constant $IDTB-BROWSE-BACK                   =  212;
define constant $IDTB-CONTENTS                      =  213;
define constant $IDTB-INDEX                         =  214;
define constant $IDTB-SEARCH                        =  215;
define constant $IDTB-HISTORY                       =  216;
define constant $IDTB-BOOKMARKS                     =  217;
define constant $IDTB-JUMP1                         =  218;
define constant $IDTB-JUMP2                         =  219;
define constant $IDTB-CUSTOMIZE                     =  221;
define constant $IDTB-ZOOM                          =  222;
define constant $IDTB-TOC-NEXT                      =  223;
define constant $IDTB-TOC-PREV                      =  224;

define C-struct <HHN-NOTIFY>
  slot hdr-value   :: <NMHDR>;
  slot pszUrl-value :: <PCSTR>;
  pointer-type-name: <LPHHN-NOTIFY>;
  c-name: "struct tagHHN_NOTIFY";
end C-struct <HHN-NOTIFY>;

define C-struct <HH-POPUP>
  slot cbStruct-value :: <C-int>;
  slot hinst-value :: <HINSTANCE>;
  slot idString-value :: <UINT>;
  slot pszText-value :: <LPCTSTR>;
  slot pt-value    :: <POINT>;
  slot clrForeground-value :: <COLORREF>;
  slot clrBackground-value :: <COLORREF>;
  slot rcMargins-value :: <RECT>;
  slot pszFont-value :: <LPCTSTR>;
  pointer-type-name: <LPHH-POPUP>;
  c-name: "struct tagHH_POPUP";
end C-struct <HH-POPUP>;

define C-struct <HH-AKLINK>
  slot cbStruct-value :: <C-int>;
  slot fReserved   :: <BOOL>;
  slot pszKeywords-value :: <LPCTSTR>;
  slot pszUrl-value :: <LPCTSTR>;
  slot pszMsgText-value :: <LPCTSTR>;
  slot pszMsgTitle-value :: <LPCTSTR>;
  slot pszWindow-value :: <LPCTSTR>;
  slot fIndexOnFail-value :: <BOOL>;
  pointer-type-name: <LPHH-AKLINK>;
  c-name: "struct tagHH_AKLINK";
end C-struct <HH-AKLINK>;

define C-struct <HH-ENUM-IT>
  slot cbStruct-value :: <C-int>;
  slot iType-value :: <C-int>;
  slot pszCatName-value :: <LPCSTR>;
  slot pszITName-value :: <LPCSTR>;
  slot pszITDescription-value :: <LPCSTR>;
  pointer-type-name: <LPHH-ENUM-IT>;
  c-name: "struct tagHH_ENUM_IT";
end C-struct <HH-ENUM-IT>;
define constant <PHH-ENUM-IT> = <LPHH-ENUM-IT>;

define C-struct <HH-ENUM-CAT>
  slot cbStruct-value :: <C-int>;
  slot pszCatName-value :: <LPCSTR>;
  slot pszCatDescription-value :: <LPCSTR>;
  pointer-type-name: <LPHH-ENUM-CAT>;
  c-name: "struct tagHH_ENUM_CAT";
end C-struct <HH-ENUM-CAT>;
define constant <PHH-ENUM-CAT> = <LPHH-ENUM-CAT>;

define C-struct <HH-SET-INFOTYPE>
  slot cbStruct-value :: <C-int>;
  slot pszCatName-value :: <LPCSTR>;
  slot pszInfoTypeName-value :: <LPCSTR>;
  pointer-type-name: <LPHH-SET-INFOTYPE>;
  c-name: "struct tagHH_SET_INFOTYPE";
end C-struct <HH-SET-INFOTYPE>;
define constant <PHH-SET-INFOTYPE> = <LPHH-SET-INFOTYPE>;
define constant <HH-INFOTYPE> = <DWORD>;
define constant <PHH-INFOTYPE> = <LPHH-INFOTYPE>;
define constant $HH-MAX-TABS                        =   19;
define constant $HH-FTS-DEFAULT-PROXIMITY           =   -1;

define C-struct <HH-FTS-QUERY>
  slot cbStruct-value :: <C-int>;
  slot fUniCodeStrings-value :: <BOOL>;
  slot pszSearchQuery-value :: <LPCTSTR>;
  slot iProximity-value :: <LONG>;
  slot fStemmedSearch-value :: <BOOL>;
  slot fTitleOnly-value :: <BOOL>;
  slot fExecute-value :: <BOOL>;
  slot pszWindow-value :: <LPCTSTR>;
  pointer-type-name: <LPHH-FTS-QUERY>;
  c-name: "struct tagHH_FTS_QUERY";
end C-struct <HH-FTS-QUERY>;

define C-struct <HH-WINTYPE>
  slot cbStruct-value :: <C-int>;
  slot fUniCodeStrings-value :: <BOOL>;
  slot pszType-value :: <LPCTSTR>;
  slot fsValidMembers-value :: <DWORD>;
  slot fsWinProperties-value :: <DWORD>;
  slot pszCaption-value :: <LPCTSTR>;
  slot dwStyles-value :: <DWORD>;
  slot dwExStyles-value :: <DWORD>;
  slot rcWindowPos-value :: <RECT>;
  slot nShowState-value :: <C-int>;
  slot hwndHelp-value :: <HWND>;
  slot hwndCaller-value :: <HWND>;
  slot paInfoTypes-value :: <LPHH-INFOTYPE>;
  slot hwndToolBar-value :: <HWND>;
  slot hwndNavigation-value :: <HWND>;
  slot hwndHTML-value :: <HWND>;
  slot iNavWidth-value :: <C-int>;
  slot rcHTML-value :: <RECT>;
  slot pszToc-value :: <LPCTSTR>;
  slot pszIndex-value :: <LPCTSTR>;
  slot pszFile-value :: <LPCTSTR>;
  slot pszHome-value :: <LPCTSTR>;
  slot fsToolBarFlags-value :: <DWORD>;
  slot fNotExpanded-value :: <BOOL>;
  slot curNavType-value :: <C-int>;
  slot tabpos-value :: <C-int>;
  slot idNotify-value :: <C-int>;
  array slot tabOrder-array :: <C-BYTE>, length: $HH-MAX-TABS + 1,
	address-getter: tabOrder-value;
  slot cHistory-value :: <C-int>;
  slot pszJump1-value :: <LPCTSTR>;
  slot pszJump2-value :: <LPCTSTR>;
  slot pszUrlJump1-value :: <LPCTSTR>;
  slot pszUrlJump2-value :: <LPCTSTR>;
  slot rcMinSize-value :: <RECT>;
  slot cbInfoTypes-value :: <C-int>;
  pointer-type-name: <LPHH-WINTYPE>;
  c-name: "struct tagHH_WINTYPE";
end C-struct <HH-WINTYPE>;
define constant <PHH-WINTYPE> = <LPHH-WINTYPE>;

define C-struct <HHNTRACK>
  slot hdr-value   :: <NMHDR>;
  slot pszCurUrl-value :: <PCSTR>;
  slot idAction-value :: <C-int>;
  slot phhWinType-value :: <LPHH-WINTYPE>;
  pointer-type-name: <LPHHNTRACK>;
  c-name: "struct tagHHNTRACK";
end C-struct <HHNTRACK>;

define C-function HtmlHelp
  parameter hwndCaller :: <HWND>;
  parameter pszFile    :: <LPCSTR>;
  parameter uCommand   :: <UINT>;
  parameter dwData     :: <DWORD>;
  result value :: <HWND>;
  c-name: "HtmlHelpA", c-modifiers: "__stdcall";
end;
