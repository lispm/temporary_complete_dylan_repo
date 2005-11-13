Module:    Motif
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// This file is automatically generated from "DrawnB.h"; do not edit.

//	RCSfile: DrawnB.h,v 
//	Revision: 1.15 
//	Date: 93/03/03 16:25:49 

define inline-only function XmIsDrawnButton (w);
  XtIsSubclass(w, xmDrawnButtonWidgetClass())
end;
define C-variable xmDrawnButtonWidgetClass :: <WidgetClass>
  c-name: "xmDrawnButtonWidgetClass";
end;
define C-subtype <XmDrawnButtonWidgetClass> ( <C-void*> ) end;
define C-subtype <XmDrawnButtonWidget> ( <C-void*> ) end;

define inline-only C-function XmCreateDrawnButton
  parameter parent     :: <Widget>;
  parameter name       :: <C-string>;
  parameter arglist    :: <ArgList>;
  parameter argcount   :: <C-Cardinal>;
  result value :: <Widget>;
  c-name: "XmCreateDrawnButton";
end;
