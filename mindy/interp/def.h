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
* $Header: /home/housel/work/rcs/gd/src/mindy/interp/def.h,v 1.1 1994/03/24 21:49:22 wlott Exp $
*
* This file does whatever.
*
\**********************************************************************/


extern void define(char *name, obj_t value);
extern void define_constant(char *name, obj_t value);
extern void define_function(char *name, obj_t specializers, boolean restp,
			    obj_t keywords, obj_t result_type,
			    obj_t (*func)());
extern void define_generic_function(char *name, int req_args, boolean restp,
				    obj_t keywords, obj_t result_types,
				    obj_t more_results_type);
extern void define_method(char *name, obj_t specializers, boolean restp,
			  obj_t keywords, obj_t result_type,
			  obj_t (*func)());
extern void define_class(char *name, obj_t class);

