/**********************************************************************\
*
*  Copyright (c) 1994  Carnegie Mellon University
*  All rights reserved.
*  
*  Use and copying of this software and preparation of derivative
*  works based on this software are permitted, including commercial
*  use, provided that the following conditions are observed:
*  
*  1. This copyright notice must be retained in full on any copies
*     and on appropriate parts of any derivative works.
*  2. Documentation (paper or online) accompanying any system that
*     incorporates this software, or any part of it, must acknowledge
*     the contribution of the Gwydion Project at Carnegie Mellon
*     University.
*  
*  This software is made available "as is".  Neither the authors nor
*  Carnegie Mellon University make any warranty about the software,
*  its performance, or its conformity to any specification.
*  
*  Bug reports, questions, comments, and suggestions should be sent by
*  E-mail to the Internet address "gwydion-bugs@cs.cmu.edu".
*
***********************************************************************
*
* $Header: /home/housel/work/rcs/gd/src/mindy/interp/mindy.h,v 1.4 1994/07/26 18:30:01 hallgren Exp $
*
\**********************************************************************/

#include <stddef.h>

extern void *malloc(size_t bytes);
extern void *realloc(void *ptr, size_t bytes);
extern void free(void *ptr);

typedef struct _object *obj_t;

struct object {
    obj_t class;
};

#define obj_is_ptr(o) (((unsigned long)(o))&1)
#define obj_ptr(type, o) ((type)(((unsigned long)(o))-1))
#define ptr_obj(ptr) ((obj_t)(((unsigned long)(ptr))+1))
#define obj_rawptr(o) ((void *)(o))
#define rawptr_obj(p) ((obj_t)(p))

extern void lose(char *fmt, ...);

#define assert(cond) \
    do { \
	if (!(cond)) \
	    lose("assertion failed, line %d file %s", __LINE__, __FILE__); \
    } while (0)

typedef int boolean;
#define TRUE 1
#define FALSE 0

#ifndef NULL
#define NULL ((void*)0)
#endif


#ifdef sparc
#define SLOW_LONGJMP 1
#endif

#ifdef hppa
#define SLOW_FUNCTION_POINTERS 1
#endif


#ifndef SLOW_LONGJMP
#define SLOW_LONGJMP 0
#endif

#ifndef SLOW_FUNCTION_POINTERS
#define SLOW_FUNCTION_POINTERS 0
#endif

#ifdef sparc
extern int printf();
extern int fprintf();
extern int fputc();
extern int fputs();
extern int fclose();
extern int fseek();
extern int isatty();
extern int fflush();
extern int vfprintf();
extern int _filbuf();
extern int _flsbuf();
extern int tolower();
extern int fsync();
#endif
