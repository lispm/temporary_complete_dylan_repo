library: opengl
author: Jeff Dubrule <igor@pobox.com>
copyright: (C) Jefferson Dubrule.  See COPYING.LIB for license details.
linker-options: -L/usr/lib/w32api -lopengl32 -lglut32 -lglu32 -lm -L/usr/X11R6/lib -lX11 -lXext -lXi -lXmu 

opengl-exports.dylan
opengl-macros.dylan
opengl-intr.dylan
opengl-glu-intr.dylan
opengl-glut-intr.dylan