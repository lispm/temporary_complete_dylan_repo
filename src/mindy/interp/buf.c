/**********************************************************************\
*
*  Copyright (C) 1994, Carnegie Mellon University
*  All rights reserved.
*
*  This code was produced by the Gwydion Project at Carnegie Mellon
*  University.  If you are interested in using this code, contact
*  "Scott.Fahlman@cs.cmu.edu" (Internet).
*
***********************************************************************
*
* $Header: /home/housel/work/rcs/gd/src/mindy/interp/buf.c,v 1.2 1994/04/09 13:35:44 wlott Exp $
*
* This file does whatever.
*
\**********************************************************************/

#include "mindy.h"
#include "gc.h"
#include "coll.h"
#include "class.h"
#include "module.h"
#include "num.h"
#include "bool.h"
#include "obj.h"
#include "error.h"
#include "list.h"
#include "def.h"
#include "sym.h"
#include "type.h"
#include "buf.h"

obj_t obj_BufferClass = NULL;

static obj_t dylan_buffer_make(obj_t class, obj_t size)
{
    int len = fixnum_value(size);
    obj_t res = alloc(obj_BufferClass, sizeof(struct buffer) + len);

    obj_ptr(struct buffer *, res)->length = len;

    return res;
}

static obj_t dylan_buffer_size(obj_t buffer)
{
    return make_fixnum(obj_ptr(struct buffer *, buffer)->length);
}

static obj_t dylan_buffer_element(obj_t buffer, obj_t index, obj_t def)
{
    int i = fixnum_value(index);

    if (0 <= i && i < obj_ptr(struct buffer *, buffer)->length)
	return make_fixnum(buffer_data(buffer)[i]);
    else if (def != obj_Unbound)
	return def;
    else {
	error("No element ~S in ~S", index, buffer);
	return NULL;
    }
}

static obj_t dylan_buffer_element_setter(obj_t val, obj_t buffer, obj_t index)
{
    int i = fixnum_value(index);

    if (0 <= i && i < obj_ptr(struct buffer *, buffer)->length)
	buffer_data(buffer)[i] = fixnum_value(val);
    else
	error("No element ~S in ~S", index, buffer);

    return val;
}


/* GC stuff. */

static int scav_buffer(struct object *ptr)
{
    struct buffer *buffer = (struct buffer *)ptr;

    return sizeof(struct buffer) + buffer->length;
}

static obj_t trans_buffer(obj_t buffer)
{
    return transport(buffer,
		     sizeof(struct buffer)
		       + obj_ptr(struct buffer *, buffer)->length);
}

void scavenge_buffer_roots(void)
{
    scavenge(&obj_BufferClass);
}



/* Init stuff. */

void make_buffer_classes(void)
{
    obj_BufferClass = make_builtin_class(scav_buffer, trans_buffer);
}

void init_buffer_classes(void)
{
    init_builtin_class(obj_BufferClass, "<buffer>", obj_VectorClass, NULL);
}

void init_buffer_functions(void)
{
    define_method("element", list2(obj_BufferClass, obj_IntegerClass),
		  FALSE, list1(pair(symbol("default"), obj_Unbound)),
		  obj_IntegerClass, dylan_buffer_element);
    define_method("element-setter",
		  list3(obj_IntegerClass, obj_BufferClass, obj_IntegerClass),
		  FALSE, obj_False, obj_ObjectClass,
		  dylan_buffer_element_setter);
    define_method("size", list1(obj_BufferClass), FALSE, obj_False,
		  obj_IntegerClass, dylan_buffer_size);
    define_method("make", list1(singleton(obj_BufferClass)), FALSE,
		  list1(pair(symbol("size"), make_fixnum(4096))),
		  obj_BufferClass, dylan_buffer_make);
}
