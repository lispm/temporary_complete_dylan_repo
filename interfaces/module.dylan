Module:    dylan-user
Author:    Andreas Bogk, Hannes Mehnert
Copyright: (C) 2005, 2006,  All rights reserved. Free for non-commercial use.

define module interfaces
  use common-dylan, exclude: { format-to-string, close };
  use dylan-extensions;
  use common-extensions, exclude: { format-to-string, close };
  use format-out, exclude: { close };
  use subseq;
  use format;
  use standard-io;
  use functional-dylan, import: { <byte-character> };
  use dylan-extensions, import: { <byte> };
  use unix-sockets, exclude: { send, connect };
  use sockets, import: { interruptible-system-call };
  use C-FFI;
  use dylan-direct-c-ffi;
  use flow;
  use packetizer, import: { parse-frame, assemble-frame, packet };
  use ethernet, import: { <ethernet-frame> };

  export <ethernet-interface>, interface-name;
end module interfaces;