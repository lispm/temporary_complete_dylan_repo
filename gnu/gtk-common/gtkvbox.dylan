Module:    gtk-common
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// This file is automatically generated from "gtkvbox.h"; do not edit.

define C-pointer-type <GtkVBox*> => <GtkVBox>;
define C-pointer-type <GtkVBox**> => <GtkVBox*>;
define C-pointer-type <GtkVBoxClass*> => <GtkVBoxClass>;
define C-pointer-type <GtkVBoxClass**> => <GtkVBoxClass*>;

define C-struct <_GtkVBox>
  sealed inline-only slot box-value      :: <GtkBox>;
  pointer-type-name: <_GtkVBox*>;
  c-name: "struct _GtkVBox";
end;

define C-struct <_GtkVBoxClass>
  sealed inline-only slot parent-class-value :: <GtkBoxClass>;
  pointer-type-name: <_GtkVBoxClass*>;
  c-name: "struct _GtkVBoxClass";
end;

define inline-only C-function gtk-vbox-get-type
  result value :: <GtkType>;
  c-name: "gtk_vbox_get_type";
end;

define inline-only C-function gtk-vbox-new
  parameter homogeneous1 :: <gboolean>;
  parameter spacing2   :: <gint>;
  result value :: <GtkWidget*>;
  c-name: "gtk_vbox_new";
end;

define inline constant <GtkVBox> = <_GtkVBox>;
define inline constant <GtkVBoxClass> = <_GtkVBoxClass>;
define sealed domain make (singleton(<_GtkVBox*>));
define sealed domain initialize (<_GtkVBox*>);
define sealed domain make (singleton(<_GtkVBoxClass*>));
define sealed domain initialize (<_GtkVBoxClass*>);