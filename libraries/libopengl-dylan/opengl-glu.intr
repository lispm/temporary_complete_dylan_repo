module: opengl-glu
synopsis: Dylan bindings for GLUT functions
author: Jeff Dubrule <igor@pobox.com>
copyright: (C) Jefferson Dubrule.  See COPYING.LIB for license details.

define interface
  #include "GL/glu.h",
    name-mapper: minimal-name-mapping,

    exclude:
    {"GLenum",
     "gluCheckExtension",
     "gluTessBeginContour",
     "gluTessEndContour",
     "gluTessBeginPolygon",
     "gluTessEndPolygon",
     "gluTessNormal",
     "gluTessProperty",
     "gluGetTessProperty"
       },
  
// Generally useful mappings:  
    map: {"char*" => <byte-string>},
    equate: {"char*" => <c-string>};

end interface;