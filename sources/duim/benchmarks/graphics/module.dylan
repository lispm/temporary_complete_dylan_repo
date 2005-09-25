Module:    Dylan-User
Author:    Andy Armstrong, Shri Amit
Synopsis:  Interactive benchmarks for DUIM graphics
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define module duim-graphics-benchmarks
  use functional-dylan;
  use simple-format;
  use simple-random;
  use threads;

  use duim;
  use duim-extended-geometry;
  //--- It would be nice not to need to do this...
  use duim-internals,
    import: { \with-abort-restart,
	      $default-text-style,
	      <basic-gadget>,
	      <oriented-gadget-mixin>,
	      collection-gadget-default-label-key,
	      <basic-frame>,
	      do-command-menu-gadgets,
	      do-copy-area,

              // Scrolling
	      <scrolling-sheet-mixin>,
	      update-scroll-bars,
	      line-scroll-amount,
	      page-scroll-amount,
	      sheet-scroll-range,
              sheet-visible-range, set-sheet-visible-range };

  // The start up function
  export start-benchmarks
end module duim-graphics-benchmarks;