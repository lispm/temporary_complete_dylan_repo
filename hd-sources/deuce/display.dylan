Module:       deuce-internals
Synopsis:     The Deuce editor
Author:       Scott McKay
Copyright:    Original Code is Copyright (c) 1996-1999 Harlequin Group plc.
	      All rights reserved.
License:      Harlequin Library Public License Version 1.0
Dual License: GNU Library General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

/// Redisplay constants

define constant $display-none    :: <integer> = 0;	// no redisplay needed
define constant $display-region  :: <integer> = 1;	// redisplay the selected region(s)
define constant $display-point   :: <integer> = 2;	// the current point moved, but text is unchanged
define constant $display-line    :: <integer> = 3;	// a single line has changed
define constant $display-text    :: <integer> = 4;	// any text in the window might have changed
define constant $display-blt     :: <integer> = 5;	// insert or delete line(s) using 'bitblt'
define constant $display-repaint :: <integer> = 6;	// the whole window needs to be redrawn
define constant $display-all     :: <integer> = 7;	// the whole window needs to be cleared and redrawn

define constant <redisplay-degree>
    = limited(<integer>, from: $display-none, to: $display-all);

// A display line models on visible line of display on the screen
define sealed class <display-line> (<object>)
  // The <line> to be displayed, or #f if there is no line
  slot display-line-line :: false-or(<basic-line>) = #f;
  // 'tick()' as of last time display line was updated on display
  slot display-line-tick  :: <integer> = $minimum-integer;
  // For text lines, the first and last characters to be displayed
  // This gets used when displaying continuation lines...
  slot display-line-start :: <integer> = 0;
  slot display-line-end   :: <integer> = 0;
  // Display line's width, height, and baseline
  slot display-line-width    :: <integer> = 0;
  slot display-line-height   :: <integer> = 0;
  slot display-line-baseline :: <integer> = 0;
  // Display line's top Y coordinate on the screen
  slot display-line-y :: <integer> = 0;
  // Start and end index of the marked region in the line, if any
  slot display-line-mark-start :: false-or(<integer>) = #f;
  slot display-line-mark-end   :: false-or(<integer>) = #f;
  // X position and width (in pixels) of marked region in the line, if any
  slot display-line-mark-x     :: false-or(<integer>) = #f;
  slot display-line-mark-width :: false-or(<integer>) = #f;
  // 'tick()' as of last time marking for this line was updated on display
  slot display-line-mark-tick  :: <integer> = $minimum-integer;
end class <display-line>;

define sealed domain make (singleton(<display-line>));
define sealed domain initialize (<display-line>);


// Line display protocol
// Note that nodes are also in the business of driving line display, but
// they do this by tailoring their 'do-lines' methods
define protocol <<line-display>> ()
  function display-line
    (line :: <line>, mode :: <major-mode>, window :: <window>,
     x :: <integer>, y :: <integer>,
     #key start: _start, end: _end, align-y) => ();
  function line-size
    (line :: <line>, mode :: <major-mode>, window :: <window>,
     #key start: _start, end: _end)
 => (width :: <integer>, height :: <integer>, baseline :: <integer>);
  // Maps from an X position on the screen to its character index within the line
  function position->index
    (line :: <line>, mode :: <major-mode>, window :: <window>, x :: <integer>)
 => (index :: <integer>);
  // Maps from a character index within a line to its X position on the screen
  function index->position
    (line :: <line>, mode :: <major-mode>, window :: <window>, index :: <integer>)
 => (x :: <integer>);
  function line-margin
    (line :: <line>, mode :: <major-mode>, window :: <window>)
 => (margin :: <integer>);
end protocol <<line-display>>;


/// Redisplay queueing

// Queue up a redisplay for a window.
// The redisplay degree is updated to be the maximum required degree.
// When the redisplay degree is $display-line, the line and index arguments
// should be supplied to indicate what line has changed.
define sealed method queue-redisplay
    (window :: <basic-window>, degree :: <redisplay-degree>,
     #key line :: false-or(<basic-line>) = #f, index :: false-or(<integer>) = #f,
          centering :: false-or(<real>) = #f)
 => (degree :: <redisplay-degree>)
  when (centering)
    set-centering-fraction(window, centering)
  end;
  let window-degree
    = queue-redisplay-1(window, degree, line: line, index: index);
  let frame :: <editor-state-mixin> = window-frame(window);
  let editor  = frame-editor(frame);
  let buffer  = frame-buffer(frame);
  let command = frame-command(frame);
  // Redisplay other windows unless the command was purely for display
  when (degree > $display-point
	& command ~== scroll-forward		//--- kludgy way to do this...
	& command ~== scroll-backward-ext
	& command ~== scroll-forward
	& command ~== scroll-backward-ext
	& command ~== force-redisplay
	& command ~== force-recenter)
    let associated-buffers = buffer-associated-buffers(buffer);
    for (other-frame :: <editor-state-mixin> in editor-frames(editor))
      when (frame-window(other-frame) ~== window)
	let other-buffer = frame-buffer(other-frame);
	case
	  other-buffer == buffer =>
	    // The same buffer is shown in another window, redisplay it
	    // exactly the same way
	    queue-redisplay-1(frame-window(other-frame), degree,
			      line: line, index: index);
	  member?(other-buffer, associated-buffers) =>
	    // An associated buffer is in another window; we'll have to
	    // work a bit harder to redisplay it, since we don't know
	    // exactly where the damage region is in that window
	    queue-redisplay-1(frame-window(other-frame), max(degree, $display-text));
	  otherwise =>
	    #f;
	end
      end
    end
  end;
  window-degree
end method queue-redisplay;
  
define sealed method queue-redisplay-1
    (window :: <basic-window>, degree :: <redisplay-degree>,
     #key line :: false-or(<basic-line>) = #f, index :: false-or(<integer>) = #f)
 => (degree :: <redisplay-degree>)
  let window-degree = window-redisplay-degree(window);
  case
    degree = $display-line =>
      case
	window-degree = $display-line =>
	  if (window-redisplay-line(window) == line)
	    // Same line, just fix the index
	    min!(window-redisplay-index(window), index)
	  else
	    if (window-redisplay-line(window))
	      // Different line, display all text
	      window-redisplay-degree(window) := $display-text
	    else
	      // No line yet, so initialize
	      window-redisplay-line(window)   := line;
	      window-redisplay-index(window)  := index
	    end
	  end;
	window-degree < $display-line =>
	  window-redisplay-degree(window) := $display-line;
	  window-redisplay-line(window)   := line;
	  window-redisplay-index(window)  := index;
      end;
    degree = $display-repaint =>
      // If we're now asking for a simple repaint and the old degree already
      // indicates a damage region, just keep the old degree
      when (window-degree < $display-line)
	window-redisplay-degree(window)  := max(window-degree, degree)
      end;
    otherwise =>
      // Maximize the redisplay degree
      when (degree = $display-blt)
	window-redisplay-line(window)  := line;
	window-redisplay-index(window) := index
      end;
      window-redisplay-degree(window)  := max(window-degree, degree);
  end;
  window-redisplay-degree(window)
end method queue-redisplay-1;

// Handy function for queuing redisplay for a given region
define function queue-region-redisplay
    (window :: <basic-window>, bp1 :: <basic-bp>, bp2 :: <basic-bp>,
     #key centering :: false-or(<real>) = #f) => ()
  if (bp-line(bp1) == bp-line(bp2))
    // Faster redisplay if the change is within a single line
    queue-redisplay(window, $display-line,
		    line: bp-line(bp1), index: min(bp-index(bp1), bp-index(bp2)),
		    centering: centering)
  else
    queue-redisplay(window, $display-text, centering: centering)
  end
end function queue-region-redisplay;


// This gets used by 'select-buffer' when it selects a new buffer for a
// window, but this is also use to clients who fill in the buffer by hand
// (for example, 'gadget-text-setter')
define method initialize-redisplay-for-buffer
    (window :: <basic-window> , buffer :: <basic-buffer>,
     #key point: _point, mark: _mark, line: _line, goal-x) => ()
  let _point = buffer-initial-point(buffer, point: _point);
  let _mark  = buffer-initial-mark(buffer,  mark:  _mark);
  let _line  = buffer-initial-line(buffer,  line:  _line);
  window-point(window)
    := _point & make(<bp>, line: bp-line(_point), index: bp-index(_point), buffer: buffer);
  window-mark(window)
    := _mark  & make(<bp>, line: bp-line(_mark),  index: bp-index(_mark),  buffer: buffer);
  window-initial-line(window)    := _line;
  window-goal-x-position(window) := goal-x | 0;
  window-line-number(window)     := #f;
  window-total-lines(window)     := #f;
  window-centering-fraction(window) := #f;
end method initialize-redisplay-for-buffer;


/// Redisplay centering

define constant <recenter-type>
    = type-union(<real>, one-of(#"top", #"bottom", #"center"));

define sealed method recenter-window
    (window :: <basic-window>, line :: <basic-line>, type :: <recenter-type>) => ()
  let font = window-default-font(window);
  let (font-width, font-height) = font-metrics(window, font);
  let (vwidth, vheight) = window-viewport-size(window);
  let vsp = window-line-spacing(window);
  ignore(font-width, vwidth);
  case
    type == #"top" =>
      // The given line goes to the top of the window
      window-initial-line(window) := line;
    type == #"bottom" =>
      // The given line goes to the bottom of the window
      // Hunt backwards for a likely line to start at
      let n = floor/(vheight, font-height + vsp) - 1;
      let line :: <basic-line>
	= bp-line(move-over-lines(line-start(line), -n, skip-test: #f));
      window-initial-line(window) := line;
    type == #"center" =>
      // The given line goes to the middle of the window
      let n = floor/(vheight, (font-height + vsp) * 2) - 1;
      let line :: <basic-line>
	= bp-line(move-over-lines(line-start(line), -n, skip-test: #f));
      window-initial-line(window) := line;
    instance?(type, <integer>) =>
      // The given line goes to the n'th line on the window
      let n = type;
      let line :: <basic-line>
	= bp-line(move-over-lines(line-start(line), -n, skip-test: #f));
      window-initial-line(window) := line;
    0.0 <= type & type <= 1.0 =>
      // The given line goes to the given fraction on the window
      let n = max(floor(floor/(vheight, font-height + vsp) * type) - 1, 0);
      let line :: <basic-line>
	= bp-line(move-over-lines(line-start(line), -n, skip-test: #f));
      window-initial-line(window) := line;
  end;
  window-line-number(window) := #f;
  window-total-lines(window) := #f;
end method recenter-window;

// Sets the centering fraction based on the direction of the motion
// of the last command 
define sealed method set-centering-fraction
    (window :: <basic-window>, centering :: <real>) => ()
  let fraction = case
		   centering < 0 => 0.2;
		   centering = 0 => 0.5;
		   centering > 0 => 0.8;
		 end;
  window-centering-fraction(window) := fraction
end method set-centering-fraction;


/// Redisplay

define sealed method redisplay-window
    (window :: <basic-window>, #key move-point? = #t) => ()
  let frame  = window-frame(window);
  let degree = window-redisplay-degree(window);
  case
    degree = $display-repaint =>
      // Pure repainting applies only to this window
      redisplay-window-within-frame(frame, window, move-point?: move-point?);
    degree > $display-point =>
      // Redisplay of changed text must be done everywhere
      //--- Should we delay displaying in windows with associated
      //--- buffers until they get repainted due to (re-)exposure?
      let editor = frame-editor(frame);
      for (window :: <basic-window> in editor-windows(editor))
	redisplay-window-within-frame(frame, window, move-point?: move-point?)
      end;
    otherwise =>
      // Just moving the point or region in this one window
      redisplay-window-within-frame(frame, window, move-point?: move-point?);
  end
end method redisplay-window;

define method redisplay-all-windows
    (#key editor) => ()
  let editor = editor | (*editor-frame* & frame-editor(*editor-frame*));
  when (editor)
    for (window :: <basic-window> in editor-windows(editor))
      queue-redisplay(window, $display-all);
      redisplay-window-within-frame(window-frame(window), window)
    end
  end
end method redisplay-all-windows;

// This generic function is so that back-ends can choose whether to redisplay
// the window within the current thread, or perhaps they may have to queue up
// an event that causes redisplay to happen in a different thread
define open generic redisplay-window-within-frame
    (frame :: <editor-state-mixin>, window :: <basic-window>, #key move-point?) => ();

// Default method just redisplays the window within this thread
define method redisplay-window-within-frame
    (frame :: <editor-state-mixin>, window :: <basic-window>, #key move-point? = #t) => ()
  do-redisplay-window(window, move-point?: move-point?)
end method redisplay-window-within-frame;

// The guts of redisplay!
define sealed method do-redisplay-window
    (window :: <basic-window>, #key move-point? = #t) => ()
  with-editor-state-bound (buffer = window)
    let show-caret? = #t;
    block (return)
      hide-caret(window, tooltip?: #t);
      unless (window-enabled?(window))
	return()
      end;
      let (width,  height)  = window-size(window);
      let (vwidth, vheight) = window-viewport-size(window);
      unless (buffer)
	clear-area(window, 0, 0, width, height);
	return()
      end;
      let degree        = window-redisplay-degree(window);
      let current-point = window-point(window);
      let current-mark  = window-mark(window);
      let current-line  = bp-line(current-point);
      let last-size     = window-last-size(window);
      let new-width?    = (vwidth  ~== head(last-size));
      let new-height?   = (vheight ~== tail(last-size));
      // If the height of the viewport changed since that last time we redisplayed,
      // we'll need to do recompute the display lines
      when (new-width? | new-height?)
	head(last-size) := vwidth;
	tail(last-size) := vheight;
	when (new-height?)
	  degree := $display-all
	end
      end;
      when (degree > $display-none)
	unhighlight-matching-thing(window);
	let mode = buffer-major-mode(buffer);
	block (break)
	  when (degree = $display-region)
	    if (current-mark) display-region-marking(window)
	    else clear-region-marking(window) end;
	    break()
	  end;						// degree = $display-region
	  when (degree = $display-point)
	    if (find-display-line(window, current-line))
	      if (current-mark) display-region-marking(window)
	      else clear-region-marking(window) end;
	      break()
	    else
	      // If the point isn't on the screen, we have to do more work
	      let old-line = window-line-number(window);
	      let new-line = bp->line-index(current-point, skip-test: #f);
	      let n-lines :: <integer> = window-n-display-lines(window);
	      let count   :: <integer>
		= if (new-line < old-line)
		    new-line - old-line			// scroll backwards
		  else
		    new-line - n-lines - old-line + 1	// scroll forwards
		  end;
	      // If the point moved to someplace that will preserve
	      // some of the lines on the screen, we can use bitblt
	      if (count ~= 0 & abs(count) < n-lines)
		scroll-n-lines(window, count);
		return()
	      else
		degree := $display-all
	      end
	    end
	  end;						// degree = $display-point
	  when (degree = $display-line)
	    // We can erase and redraw a single line
	    let line  :: <basic-line> = window-redisplay-line(window);
	    let index :: <integer>    = window-redisplay-index(window);
	    // First clear the old line's area if it's on the screen
	    let dline = find-display-line(window, line);
	    if (dline)
	      // We can reduce flicker by clearing and displaying less,
	      // but we can only get away with this if we are not clearing
	      // the mark or dealing with a line with tabs in it
	      let marked?
		= display-line-mark-x(dline)
		  | position(line-contents(line), '\t', start: index, end: line-length(line));
	      let dline :: <display-line> = dline;	// force tighter type...
	      let (dx, dy)
		= values(if (marked?) 0 else index->position(line, mode, window, index) end,
			 display-line-y(dline));
	      let (dw, dh)
		= values(width, display-line-height(dline));
	      clear-area(window, dx, dy, dx + dw, dy + dh);
	      update-display-lines(window, degree: degree);
	      if (current-mark) update-display-line-marking(window)
	      else clear-region-marking(window) end;
	      // Now redraw the new contents of the line
	      let dline :: <display-line>
		= find-display-line(window, line)
		  | error("Can't find a display line for line %=", line);
	      let (dx, dy)
		= values(if (marked?) 0 else index->position(line, mode, window, index) - line-margin(line, mode, window) end,
			 display-line-y(dline));
	      let mark-x = display-line-mark-x(dline);
	      when (mark-x)
		display-line-mark-tick(dline) := display-line-tick(dline);
		let mw = display-line-mark-width(dline);
		let mh = display-line-height(dline);
		draw-rectangle(window, mark-x, dy, mark-x + mw, dy + mh + 1,
			       color: $region-marking-color,
			       filled?: #t)
	      end;
	      display-line(line, mode, window, dx, dy + display-line-baseline(dline),
			   start: if (marked?) display-line-start(dline) else index end,
			   end: display-line-end(dline),
			   align-y: #"baseline");
	      display-line-tick(dline) := line-modification-tick(line);
	      display-region-marking(window);
	      break()
	    else
	      // This line was not on the screen, we need to redisplay harder
	      degree := $display-all
	    end
	  end;						// degree = $display-line
	  // See if we can do insert/delete line optimizations
	  when (degree = $display-blt)
	    let line  :: <basic-line> = window-redisplay-line(window);
	    let count :: <integer>    = window-redisplay-index(window);
	    let (dline, hint) = find-display-line(window, line);
	    if (~dline | window-occluded?(window))
	      // If we can't find a dline or the window is occluded, bitblt won't work
	      degree := $display-text
	    else
	      let n-lines :: <integer> = window-n-display-lines(window);
	      let index   :: <integer> = hint - 1;
	      if (index + abs(count) < n-lines)
		// If the number of lines we are inserting/deleting fits on
		// the screen, we can do the bitblt optimization
		case
		  count < 0 =>
		    delete-display-lines(window, line, index, -count);
		  count > 0 =>
		    insert-display-lines(window, line, index,  count);
		  otherwise =>
		    #f;
		end;
		return()
	      else
		degree := $display-text
	      end
	    end
	  end;						// degree = $display-blt
	  when (degree >= $display-text)
	    // Now redisplay the changed contents of the window
	    when (move-point?
		  & ~find-display-line(window, current-line, compulsive?: #t))
	      ensure-line-visible(window, buffer, current-line)
	    end;
	    let redisplay-y = update-display-lines(window, degree: degree);
	    when (redisplay-y)
	      // If we can clear a large region, do it now
	      clear-area(window, 0, redisplay-y, width, height)
	    end;
	    unless (degree = $display-repaint)
	      update-display-line-marking(window, move-point?: move-point?)
	    end;
	    let lines   :: <simple-object-vector> = window-display-lines(window);
	    let n-lines :: <integer> = window-n-display-lines(window);
	    // Now redisplay all the lines that need it
	    without-bounds-checks
	      for (i :: <integer> from 0 below n-lines)
		let dline :: <display-line> = lines[i];
		let line  :: <basic-line>   = display-line-line(dline);
		let (dx, dy) = values(0, display-line-y(dline));
		when (display-line-tick(dline) < line-modification-tick(line))
		  display-line-tick(dline) := line-modification-tick(line);
		  when ((~redisplay-y & degree ~= $display-repaint)
			| (redisplay-y & dy < redisplay-y))
		    // If we didn't clear the whole area, we need to clear this line
		    // We might need to clear the odd line before the big area, too
		    let (dw, dh) = values(width, display-line-height(dline));
		    clear-area(window, dx, dy, dx + dw, dy + dh)
		  end;
		  // Display the marked region, if any
		  let mark-x = display-line-mark-x(dline);
		  when (mark-x
			& (display-line-mark-tick(dline) < display-line-tick(dline)
			   | degree = $display-repaint))
		    display-line-mark-tick(dline) := display-line-tick(dline);
		    let mw = display-line-mark-width(dline);
		    let mh = display-line-height(dline);
		    draw-rectangle(window, mark-x, dy, mark-x + mw, dy + mh + 1,
				   color: $region-marking-color,
				   filled?: #t)
		  end;
		  // Now we can finally display the line
		  display-line(line, mode, window, dx, dy + display-line-baseline(dline),
			       start: display-line-start(dline), end: display-line-end(dline),
			       align-y: #"baseline")
		end
	      end
	    end
	  end;						// degree >= $display-text
	end block;
	when (degree >= $display-point)
	  // Don't bother to update the scroll bars for simple repaints
	  when (degree ~= $display-repaint | new-width? | new-height?)
	    update-scroll-bars(window, buffer)
	  end;
	  // Finally, set the caret position
	  unless (degree = $display-repaint)
	    show-caret? := update-caret-position(window, buffer, move-point?: move-point?)
	  end
	end;
	when (degree >= $display-none)
	  highlight-matching-thing(window)
	end
      end;
    cleanup
      window-redisplay-degree(window)   := $display-none;
      window-redisplay-line(window)     := #f;
      window-redisplay-index(window)    := #f;
      window-centering-fraction(window) := #f;
      when (show-caret?)
	show-caret(window, tooltip?: #t)
      end;
    end block;
  end
end method do-redisplay-window;


/// Redisplay helper functions

define sealed method update-scroll-bars
    (window :: <basic-window>, buffer :: <basic-buffer>) => ()
  let n-lines :: <integer> = window-n-display-lines(window);
  // Update the horizontal scroll bar first, because it can
  // mess up the vertical scroll bar
  let max-width = window-max-line-width(window);
  let (vwidth, vheight) = window-viewport-size(window);
  ignore(vheight);
  update-scroll-bar(window, #"horizontal",
		    max-width, -1, vwidth);
  // Then update the vertical scroll bar
  let total-lines = window-total-lines(window);
  let line-number = window-line-number(window);
  update-scroll-bar(window, #"vertical",
		    total-lines, line-number, n-lines)
end method update-scroll-bars;


define sealed method update-caret-position
    (window :: <basic-window>, buffer :: <basic-buffer>, #key move-point? = #t)
 => (visible? :: <boolean>)
  let n-lines :: <integer> = window-n-display-lines(window);
  let n :: <integer> = 0;
  let visible? :: <boolean> = #f;
  while (n < 2)
    let bp       = window-point(window);
    let fraction = window-centering-fraction(window);
    when (structural-diagram-line?(bp-line(bp)))
      bp := move-over-lines(bp, if (fraction & fraction < 0.5) -1 else 1 end)
    end;
    let (x, y)
      = ~structural-diagram-line?(bp-line(bp)) & bp->position(window, bp);
    case
      x & y =>
	// Set the caret position, scrolling it into view horizontally if necessary
	set-caret-position(window, x, y);
	let (sx, sy) = scroll-position(window);
	let (vw, vh) = window-viewport-size(window);
	ignore(sy, vh);
	let char-width = string-size(window, " ");
	let (x-, x+)   = values(x - char-width, x + char-width);
	case
	  x- < sx =>
	    let margin = line-margin(bp-line(bp), buffer-major-mode(buffer), window);
	    when (x- <= margin) x- := 0 end;
	    set-scroll-position(window, max(0, x-), #f);
	  x+ >= sx + vw =>
	    let dx = x+ - (sx + vw);
	    set-scroll-position(window, sx + dx, #f);
	end;
	inc!(n, 2);
	visible? := #t;
      move-point? =>
	// Somehow the point isn't on the screen, move it to the
	// top or bottom and try again
	let lines :: <simple-object-vector> = window-display-lines(window);
	let dline :: <display-line>
	  = case
	      fraction & fraction < 0.5 =>
		adjust-display-line(lines, 0, n-lines, 1);
	      fraction & fraction > 0.5 =>
		adjust-display-line(lines, n-lines - 1, n-lines, -1);
	      otherwise =>
		adjust-display-line(lines, floor/(n-lines, 2), n-lines, 1);
	    end;
	move-point!(display-line-line(dline), index: 0, window: window);
	inc!(n, 1);
      otherwise =>
	inc!(n, 2);
    end
  end;
  visible?
end method update-caret-position;

// Don't let the line we're moving the caret to fall on a diagram line
define method adjust-display-line
    (lines :: <simple-object-vector>, index :: <integer>, n-lines :: <integer>,
     delta :: <integer>)
 => (line :: <display-line>)
  let line :: <display-line> = lines[index];
  block (break)
    while (structural-diagram-line?(display-line-line(line)))
      index := index + delta;
      when (index < 0 | index >= n-lines)
	break()
      end;
      line := lines[index]
    end
  end;
  line
end method adjust-display-line;


/// Maintaining the display line structure

// Returns the Y coordinate of the first line at which the display
// changed significantly (that is, everything past that point needs
// to be cleared and redrawn)
define sealed method update-display-lines
    (window :: <basic-window>, #key degree)
 => (redisplay-y :: false-or(<integer>))
  let buffer = window-buffer(window);
  let mode   = buffer-major-mode(buffer);
  let degree = degree | window-redisplay-degree(window);
  let (width, height) = window-size(window);
  let vsp = window-line-spacing(window);
  let lines   :: <simple-object-vector> = window-display-lines(window);
  let n-slots :: <integer> = size(lines);	// the number of slots we have for display lines
  let n-lines :: <integer> = 0;			// running number of active display lines
  let line-x  :: <integer> = 0;
  let line-y  :: <integer> = 0;
  let max-width   :: <integer> = 0;
  let redisplay-y :: false-or(<integer>) = #f;
  let old-n :: <integer> = window-n-display-lines(window);
  let old-y :: <integer> = if (old-n > 0) display-line-y(lines[old-n - 1]) else 0 end;
  block (break)
    without-bounds-checks
      local method measure-line (line :: <basic-line>)
	      let dline = (n-lines < n-slots) & lines[n-lines];
	      let same-line? = (degree < $display-all)
			       & dline & (display-line-line(dline) == line);
	      let update? = #t;
	      let (old-width :: <integer>, old-height :: <integer>, old-baseline :: <integer>)
		= if (same-line?)
		    values(display-line-width(dline), display-line-height(dline),
			   display-line-baseline(dline))
		  else
		    values(0, 0, 0)
		  end;
	      let (line-width :: <integer>, line-height :: <integer>, line-baseline :: <integer>)
		= if (same-line?
		      & display-line-tick(dline) >= line-modification-tick(line))
		    // The old display line is valid, use it
		    update? := #f;
		    values(old-width, old-height, old-baseline)
		  else
		    // Looks like we have to measure the line again
		    let (line-width, line-height, line-baseline)
		      = line-size(line, mode, window);
		    inc!(line-height, vsp);
		    // Get a new display line, growing the set of display lines
		    // if we don't have enough.  We create a bunch display lines
		    // all at once (and don't discard) them so that we can keep
		    // them localized in memory.
		    unless (dline)
		      let new-size :: <integer>
			= min(height, floor(max(ceiling/(height, 10), n-slots * 1.5)));
		      let new-lines :: <simple-object-vector>
			= make(<simple-object-vector>, size: new-size);
		      for (j :: <integer> from 0 below n-slots)
			new-lines[j] := lines[j]
		      end;
		      for (j :: <integer> from n-slots below new-size)
			new-lines[j] := make(<display-line>)
		      end;
		      window-display-lines(window) := new-lines;
		      lines   := new-lines;
		      n-slots := new-size
		    end;
		    // If the height of this line changed or we are forcing a display,
		    // we need to clear from here
		    when (degree = $display-all | line-height ~= old-height)
		      redisplay-y := redisplay-y | line-y
		    end;
		    dline := lines[n-lines];
		    values(line-width, line-height, line-baseline)
		  end;
	      let dline :: <display-line> = dline;	// force tighter type...
	      // Create (or update) the display line
	      // Note that the display tick gets bumped up when we display the line
	      when (update?)
		display-line-line(dline)     := line;
		display-line-start(dline)    := 0;
		display-line-end(dline)      := line-length(line);
		display-line-width(dline)    := line-width;
		display-line-height(dline)   := line-height;
		display-line-baseline(dline) := line-baseline;
		display-line-y(dline)        := line-y;
		display-line-mark-start(dline) := #f;
		display-line-mark-end(dline)   := #f;
		display-line-mark-x(dline)     := #f;
		display-line-mark-width(dline) := #f;
		display-line-mark-tick(dline)  := $minimum-integer
	      end;
	      when (redisplay-y | degree = $display-repaint)
		// If we have to clear a region, ensure this line gets redrawn
		display-line-tick(dline) := $minimum-integer
	      end;
	      line-y := line-y + line-height;
	      max!(max-width, line-width);
	      // If the new line y is _greater_ the height of the screen, then
	      // the line we just computed will only be partially displayed.
	      // In that case, we don't display it at all unless it would be
	      // the only line on the screen.
	      if (line-y > height)
		max!(n-lines, 1);
		break()
	      else
		n-lines := n-lines + 1
	      end
	    end method;
      let initial-line = window-initial-line(window)
			 | bp-line(interval-start-bp(buffer));
      for (line = initial-line
	     then line-next-in-buffer(line, buffer, skip-test: #f),
	   while: line)
	measure-line(line)
      end
    end
  end block;
  window-n-display-lines(window) := n-lines;
  window-max-line-width(window)  := max-width;
  if (n-lines > 0 & old-y > display-line-y(lines[n-lines - 1]))
    // The total display shrank, we'll need to clear the end
    display-line-y(lines[n-lines - 1])
  else
    if (n-lines = 0) 0 else redisplay-y end
  end
end method update-display-lines;

define sealed method find-display-line
    (window :: <basic-window>, line :: <basic-line>,
     #key hint :: false-or(<integer>) = #f, compulsive? = #f)
 => (display-line :: false-or(<display-line>), hint :: false-or(<integer>))
  let n-lines :: <integer> = window-n-display-lines(window);
  let cached-dline :: false-or(<display-line>)
    = ~compulsive? & window-display-line-cache(window);
  if (cached-dline
      & display-line-line(cached-dline) == line
      & window-display-line-hint(window) < n-lines)
    values(cached-dline, window-display-line-hint(window))
  else
    without-bounds-checks
      let lines :: <simple-object-vector>
        = window-display-lines(window);
      let dline :: false-or(<display-line>)
        = ~compulsive? & hint & (hint < n-lines) & lines[hint];
      if (dline & display-line-line(dline) == line)
	window-display-line-cache(window) := dline;
	window-display-line-hint(window)  := hint + 1;
	values(dline, hint + 1)
      else
	block (return)
	  for (i :: <integer> from 0 below n-lines)
	    let dline :: <display-line> = lines[i];
	    when (display-line-line(dline) == line)
	      when (compulsive?)
		// If we're being "compulsive", we need to verify that the
		// number of lines in the displayed interval is the same as
		// the number of lines in the buffer in the same interval.
		// This guards against inserting lines in the buffer that
		// would causes us to erroneously match a display line when
		// we are about to push that display line off the screen.
		// This arises, e.g., when the Interactor is about to
		// display a dozen values in an output section when the
		// point is only a few lines from the bottom.
		//--- Yeah, "compulsive" is a kludge.  Sorry about that.
		let buffer :: <basic-buffer> = window-buffer(window);
		for (n :: <integer> from 0,
		     l = display-line-line(lines[0])
		       then line-next-in-buffer(l, buffer, skip-test: #f),
		     until: ~l | l == line)
		finally
		  when (n ~= i)
		    return(#f, #f)
		  end
		end
	      end;
	      window-display-line-cache(window) := dline;
	      window-display-line-hint(window)  := i + 1;
	      return(dline, i + 1)
	    end
	  end;
	  values(#f, #f)
	end block;
      end
    end
  end
end method find-display-line;

define sealed method ensure-line-visible
    (window :: <basic-window>, buffer :: <basic-buffer>, line :: <basic-line>) => ()
  block (return)
    let last? = (line == bp-line(interval-end-bp(buffer)));
    // If it's the new last line in the buffer, it will likely be visible if
    // there's a bit of space after the penultimate line
    // Note that '(line == bp-line(interval-end-bp(buffer)))' suffices to
    // test for a _new_ last line because 'ensure-line-visible' will only be
    // called when 'line' has no corresponding display line
    when (last?)
      let prev = line-previous-in-buffer(line, buffer) | line;
      let (dline, hint)     = find-display-line(window, prev);
      let (vwidth, vheight) = window-viewport-size(window);
      ignore(hint, vwidth);
      when (dline & (display-line-y(dline) + display-line-height(dline) * 2) < vheight)
	return()
      end
    end;
    let fraction = window-centering-fraction(window) | #"center";
    recenter-window(window, line, fraction)
  end
end method ensure-line-visible;


/// Insert line and delete line optimizations

// n > 0 means we're scrolling up   (forward)
// n < 0 means we're scrolling down (backward)
define sealed method scroll-n-lines
    (window :: <basic-window>, n :: <integer>, #key move-point? = #t)
 => (dy :: <integer>)
  if (window-enabled?(window))
    let line :: <basic-line> = display-line-line(window-display-lines(window)[0]);
    case
      n > 0 =>
	// Scrolling up is like deleting display lines at the top, but
	// be sure to avoid scrolling the very last line off the screen
	let n-lines :: <integer> = window-n-display-lines(window);
	min!(n, n-lines - 1);
	if (n > 0)
	  if (window-occluded?(window))
	    scroll-n-lines-slowly(window, n, move-point?: move-point?)
	  else
	    delete-display-lines(window, line, 0,  n, move-point?: move-point?)
	  end
	else
	  0
	end;
      n < 0 =>
	// Scrolling down is like inserting display lines at the top, but
	// first figure out which line should be the initial display line
	let n      :: <integer> = -n;
	let min-n  :: <integer> = 0;
	let buffer :: <basic-buffer> = window-buffer(window);
	for (i :: <integer> from 0 below n,
	     prev = line-previous-in-buffer(line, buffer, skip-test: #f)
	       then line-previous-in-buffer(prev, buffer, skip-test: #f),
	     while: prev)
	  line := prev;
	  inc!(min-n)
	end;
	min!(n, min-n);
	if (n > 0)
	  if (window-occluded?(window))
	    scroll-n-lines-slowly(window, -n, move-point?: move-point?)
	  else
	    insert-display-lines(window, line, 0, n, move-point?: move-point?)
	  end
	else
	  0
	end;
      otherwise =>
	0;
    end
  else
    0
  end
end method scroll-n-lines;

define sealed method scroll-n-lines-slowly
    (window :: <basic-window>, n :: <integer>, #key move-point? = #t)
 => (dy :: <integer>)
  ignore(move-point?);
  let dlines :: <simple-object-vector> = window-display-lines(window);
  let dline  :: <display-line> = dlines[0];
  let line   :: <basic-line>   = display-line-line(dline);
  let line   :: <basic-line>
    = bp-line(move-over-lines(line-start(line), n, skip-test: #f));
  recenter-window(window, line, #"top");
  window-centering-fraction(window) := #f;
  queue-redisplay(window, $display-all);
  do-redisplay-window(window, move-point?: move-point?);
  //--- This isn't right, but we can get away with it since the only thing
  //--- that looks at the DY value (in drag-selection) won't use this...
  0
end method scroll-n-lines-slowly;


// Insert and display 'n' display lines at the given index,
// using bitblt to move to existing lines down
define sealed method insert-display-lines
    (window :: <basic-window>,
     line :: <basic-line>, index :: <integer>, n :: <integer>,
     #key move-point? = #t)
 => (dy :: <integer>)
  let show-caret? = #t;
  block ()
    hide-caret(window, tooltip?: #t);
    let (width, height) = window-size(window);
    ignore(width);
    let buffer  :: <basic-buffer> = window-buffer(window);
    let mode    :: <major-mode>   = buffer-major-mode(buffer);
    let lines   :: <simple-object-vector> = window-display-lines(window);
    let n-lines :: <integer> = window-n-display-lines(window);
    let n-slots :: <integer> = size(lines);
    let line-y  :: <integer> = display-line-y(lines[index]);
    let max-width :: <integer> = 0;
    let box-y1    :: <integer> = line-y;
    // If this line is modified, we might need to redisplay a bit more
    // This comes up during 'insert-newline' and 'open-line', e.g.
    let inc? = display-line-tick(lines[index])
		 < line-modification-tick(display-line-line(lines[index]));
    // Make a hole for 'n' new display lines, growing the underlying vector
    // if needed.  We'll update the 'window-n-display-lines' later after we
    // sum the line heights to decide how many to show.
    let (from-lines :: <simple-object-vector>,
	 to-lines   :: <simple-object-vector>)
      = if (n-lines + n > n-slots)
          let new-size  :: <integer> = n-lines + n;
	  let old-lines :: <simple-object-vector> = lines;
	  let new-lines :: <simple-object-vector> = make(<vector>, size: new-size);
	  without-bounds-checks
	    for (i :: <integer> from 0 below n-slots)
	      new-lines[i] := old-lines[i]
	    end;
	    for (i :: <integer> from n-slots below new-size)
	      new-lines[i] := make(<display-line>)
	    end
	  end;
	  n-slots := new-size;
	  lines   := new-lines;
	  window-display-lines(window) := new-lines;
	  values(old-lines, new-lines)
	else
	  values(lines, lines)
	end;
    without-bounds-checks
      for (i :: <integer> from n-slots - n - 1 to index by -1)
	let from :: <display-line> = from-lines[i];
	let to   :: <display-line> = to-lines[i + n];
	copy-display-line-into!(from, to)
      end
    end;
    // Fill in the new display lines
    when (inc?)
      inc!(n)
    end;
    n-lines := index;
    let vsp  = window-line-spacing(window);
    let next = #f;
    let reached-bottom?
      = block (break)
	  local method measure-line
		    (line :: <basic-line>, dline :: <display-line>) => ()
		  let (line-width, line-height, line-baseline)
		    = line-size(line, mode, window);
		  inc!(line-height, vsp);
		  display-line-line(dline)     := line;
		  display-line-tick(dline)     := $minimum-integer;
		  display-line-start(dline)    := 0;
		  display-line-end(dline)      := line-length(line);
		  display-line-width(dline)    := line-width;
		  display-line-height(dline)   := line-height;
		  display-line-baseline(dline) := line-baseline;
		  display-line-y(dline)        := line-y;
		  display-line-mark-start(dline) := #f;
		  display-line-mark-end(dline)   := #f;
		  display-line-mark-x(dline)     := #f;
		  display-line-mark-width(dline) := #f;
		  display-line-mark-tick(dline)  := $minimum-integer;
		  line-y := line-y + line-height;
		  max!(max-width, line-width);
		  if (line-y > height)
		    max!(n-lines, 1);
		    break(#t)
		  else
		    n-lines := n-lines + 1
		  end
		end method;
	  without-bounds-checks
	    for (i :: <integer> from index below index + n,
		 line = line
		   then line-next-in-buffer(line, buffer, skip-test: #f),
		 while: line)
	      measure-line(line, lines[i])
	    finally
	      next := line
	    end
	  end;
          #f;				// we haven't reached the bottom of the window
	end;
    window-initial-line(window) := display-line-line(lines[0]);
    let box-y2 :: <integer> = line-y;
    when (next & ~reached-bottom?)
      // Fix the Y positions of the lines we moved down,
      // unless they're off the bottom of the screen now
      block (break)
	without-bounds-checks
	  for (i :: <integer> from index + n below n-slots,
	       line = line-next-in-buffer(next, buffer, skip-test: #f)
		 then line-next-in-buffer(line, buffer, skip-test: #f),
	       while: line)
	    let dline :: <display-line> = lines[i];
	    display-line-y(dline) := line-y;
	    line-y := line-y + display-line-height(dline);
	    max!(max-width, display-line-width(dline));
	    if (line-y > height)
	      max!(n-lines, 1);
	      break()
	    else
	      n-lines := n-lines + 1
	    end
	  end
	end
      end block;
    end;
    window-n-display-lines(window) := n-lines;
    window-max-line-width(window)  := max-width;
    // Bitblt the old display lines down
    let (vwidth, vheight) = window-viewport-size(window);
    let box-y2-prime :: <integer>
      = if (inc?) box-y2 - display-line-height(lines[index + n - 1]) else box-y2 end;
    let height :: <integer> = box-y2 - box-y1;
    let (sx, sy) = scroll-position(window);
    ignore(sy);
    copy-area(window,
	      sx, box-y1, vwidth, vheight - height,
	      sx, box-y2-prime);
    // Clear out the area in which the new display lines live
    clear-area(window,
	       sx, box-y1, sx + vwidth, box-y2);
    // Finally draw the new display lines, taking care to ensure that
    // we redraw any lines that need to be marked
    let start-n  = index;
    let old-mark = index + n < n-lines & display-line-mark-x(lines[index + n]);
    update-display-line-marking(window, move-point?: move-point?);
    let new-mark = index + n < n-lines & display-line-mark-x(lines[index + n]);
    let end-n    = if (inc? | old-mark ~= new-mark) index + n else index + n + 1 end;
    without-bounds-checks
      for (i :: <integer> from start-n below end-n)
	let dline :: <display-line> = lines[i];
	let line  :: <basic-line>   = display-line-line(dline);
	let (dx, dy) = values(0, display-line-y(dline));
	display-line-tick(dline) := line-modification-tick(line);
	let mark-x = display-line-mark-x(dline);
	when (mark-x)
	  display-line-mark-tick(dline) := display-line-tick(dline);
	  let mw = display-line-mark-width(dline);
	  let mh = display-line-height(dline);
	  draw-rectangle(window, mark-x, dy, mark-x + mw, dy + mh + 1,
			 color: $region-marking-color,
			 filled?: #t)
	end;
	display-line(line, mode, window, dx, dy + display-line-baseline(dline),
		     start: display-line-start(dline), end: display-line-end(dline),
		     align-y: #"baseline")
      end
    end;
    set-centering-fraction(window, 1);
    when (window.%line-number)
      window-line-number(window) := window.%line-number - n
    end;
    update-scroll-bars(window, buffer);
    show-caret? := update-caret-position(window, buffer, move-point?: move-point?);
    height;
  cleanup
    window-redisplay-line(window)   := #f;
    window-redisplay-index(window)  := #f;
    window-redisplay-degree(window) := $display-none;
    when (show-caret?)
      show-caret(window, tooltip?: #t)
    end;
  end
end method insert-display-lines;

// Delete 'n' display lines at the given index,
// using bitblt to move to existing lines up, 
// displaying new lines at the bottom of the display
define sealed method delete-display-lines
    (window :: <basic-window>,
     line :: <basic-line>, index :: <integer>, n :: <integer>,
     #key move-point? = #t)
 => (dy :: <integer>)
  let show-caret? = #t;
  block ()
    hide-caret(window, tooltip?: #t);
    let buffer  :: <basic-buffer> = window-buffer(window);
    let mode    :: <major-mode>   = buffer-major-mode(buffer);
    let lines   :: <simple-object-vector> = window-display-lines(window);
    let n-lines :: <integer> = window-n-display-lines(window);
    // Compute the height of the top 'n' lines on the display,
    // which is the region we will move via 'copy-area'
    let line-y  :: <integer> = display-line-y(lines[index]);
    let box-y1  :: <integer> = line-y;
    let box-y2  :: <integer> = display-line-y(lines[n - 1]) + display-line-height(lines[n - 1]);
    // Pull all of the display lines up from the bottom,
    // adjusting their Y position as we go
    without-bounds-checks
      for (i :: <integer> from index + n below n-lines)
	let from :: <display-line> = lines[i];
	let to   :: <display-line> = lines[i - n];
	copy-display-line-into!(from, to);
	display-line-y(to) := line-y;
	line-y := line-y + display-line-height(to)
      end
    end;
    // Fill in the new display lines at the bottom
    let vsp = window-line-spacing(window);
    local method measure-line
	      (line :: <basic-line>, dline :: <display-line>) => ()
	    let (line-width, line-height, line-baseline)
	      = line-size(line, mode, window);
	    inc!(line-height, vsp);
	    display-line-line(dline)     := line;
	    display-line-tick(dline)     := $minimum-integer;
	    display-line-start(dline)    := 0;
	    display-line-end(dline)      := line-length(line);
	    display-line-width(dline)    := line-width;
	    display-line-height(dline)   := line-height;
	    display-line-baseline(dline) := line-baseline;
	    display-line-y(dline)        := line-y;
	    display-line-mark-start(dline) := #f;
	    display-line-mark-end(dline)   := #f;
	    display-line-mark-x(dline)     := #f;
	    display-line-mark-width(dline) := #f;
	    display-line-mark-tick(dline)  := $minimum-integer;
	    line-y := line-y + line-height
	  end method;
    without-bounds-checks
      let line :: <basic-line> = display-line-line(lines[n-lines - 1]);
      for (i :: <integer> from index + n-lines - n below n-lines,
	   line = line-next-in-buffer(line, buffer, skip-test: #f)
	     then line-next-in-buffer(line, buffer, skip-test: #f),
	   while: line)
	measure-line(line, lines[i])
      finally
	n-lines := i;				// might have run out of lines...
        window-n-display-lines(window) := n-lines
      end
    end;
    window-initial-line(window) := display-line-line(lines[0]);
    // Bitblt the saved display lines up
    let (vwidth, vheight) = window-viewport-size(window);
    let height :: <integer> = box-y2 - box-y1;
    let (sx, sy) = scroll-position(window);
    ignore(sy);
    copy-area(window,
	      sx, box-y2, vwidth, vheight - height,
	      sx, box-y1);
    // Clear out the bottom part of the display
    clear-area(window,
	       sx, vheight - height, sx + vwidth, vheight);
    // Finally draw the new display lines, taking care to ensure that
    // we redraw any lines that need to be marked
    let old-mark = n-lines - n > 0 & display-line-mark-x(lines[n-lines - n - 1]);
    update-display-line-marking(window, move-point?: move-point?);
    let new-mark = n-lines - n > 0 & display-line-mark-x(lines[n-lines - n - 1]);
    let start-n  = if (old-mark ~= new-mark) n-lines - n - 1 else n-lines - n end;
    let end-n    = n-lines;
    without-bounds-checks
      for (i :: <integer> from max(start-n, 0) below end-n)
	let dline :: <display-line> = lines[i];
	let line  :: <basic-line>   = display-line-line(dline);
	let (dx, dy) = values(0, display-line-y(dline));
	display-line-tick(dline) := line-modification-tick(line);
	let mark-x = display-line-mark-x(dline);
	when (mark-x)
	  display-line-mark-tick(dline) := display-line-tick(dline);
	  let mw = display-line-mark-width(dline);
	  let mh = display-line-height(dline);
	  draw-rectangle(window, mark-x, dy, mark-x + mw, dy + mh + 1,
			 color: $region-marking-color,
			 filled?: #t)
	end;
	display-line(line, mode, window, dx, dy + display-line-baseline(dline),
		     start: display-line-start(dline), end: display-line-end(dline),
		     align-y: #"baseline")
      end
    end;
    set-centering-fraction(window, -1);
    when (window.%line-number)
      window-line-number(window) := window.%line-number + n
    end;
    update-scroll-bars(window, buffer);
    show-caret? := update-caret-position(window, buffer, move-point?: move-point?);
    height;
  cleanup
    window-redisplay-line(window)   := #f;
    window-redisplay-index(window)  := #f;
    window-redisplay-degree(window) := $display-none;
    when (show-caret?)
      show-caret(window, tooltip?: #t)
    end;
  end
end method delete-display-lines;


define sealed method copy-display-line-into!
    (from :: <display-line>, to :: <display-line>)
 => (to :: <display-line>)
  display-line-line(to)     := display-line-line(from);
  display-line-tick(to)     := display-line-tick(from);
  display-line-start(to)    := display-line-start(from);
  display-line-end(to)      := display-line-end(from);
  display-line-width(to)    := display-line-width(from);
  display-line-height(to)   := display-line-height(from);
  display-line-baseline(to) := display-line-baseline(from);
  display-line-y(to)        := display-line-y(from);
  display-line-mark-start(to) := display-line-mark-start(from);
  display-line-mark-end(to)   := display-line-mark-end(from);
  display-line-mark-x(to)     := display-line-mark-x(from);
  display-line-mark-width(to) := display-line-mark-width(from);
  display-line-mark-tick(to)  := display-line-mark-tick(from);
  to
end method copy-display-line-into!;


/// Region marking

define variable $region-marking-color = make-color(210, 210, 210);

// Clear the old marking, and reset each display line to be unmarked
define sealed method clear-region-marking
    (window :: <basic-window>) => ()
  let buffer  = window-buffer(window);
  let mode    = buffer-major-mode(buffer);
  let lines   :: <simple-object-vector> = window-display-lines(window);
  let n-lines :: <integer> = window-n-display-lines(window);
  without-bounds-checks
    for (i :: <integer> from 0 below n-lines)
      let dline :: <display-line> = lines[i];
      let x = display-line-mark-x(dline);
      when (x)
	let y = display-line-y(dline);
	let w = display-line-mark-width(dline);
	let h = display-line-height(dline);
	clear-area(window, x, y, x + w, y + h);
	let line = display-line-line(dline);
	display-line(line, mode, window, 0, y + display-line-baseline(dline),
		     start: display-line-start(dline), end: display-line-end(dline),
		     align-y: #"baseline");
	display-line-mark-start(dline) := #f;
	display-line-mark-end(dline)   := #f;
	display-line-mark-x(dline)     := #f;
	display-line-mark-width(dline) := #f;
	display-line-mark-tick(dline)  := $minimum-integer
      end
    end
  end
end method clear-region-marking;

// Redisplay everything that needs to be marked
// This assumes that all the display lines have been updated
// NB: must be called with the caret hidden
define sealed method display-region-marking
    (window :: <basic-window>) => ()
  when (window-mark(window))
    update-display-line-marking(window);
    let buffer  = window-buffer(window);
    let mode    = buffer-major-mode(buffer);
    let lines   :: <simple-object-vector> = window-display-lines(window);
    let n-lines :: <integer> = window-n-display-lines(window);
    without-bounds-checks
      for (i :: <integer> from 0 below n-lines)
	let dline :: <display-line> = lines[i];
	let mark-x = display-line-mark-x(dline);
	when (mark-x
	      & display-line-mark-tick(dline) < display-line-tick(dline))
	  display-line-mark-tick(dline) := display-line-tick(dline);
	  let y  = display-line-y(dline);
	  let mw = display-line-mark-width(dline);
	  let mh = display-line-height(dline);
	  draw-rectangle(window, mark-x, y, mark-x + mw, y + mh + 1,
			 color: $region-marking-color,
			 filled?: #t);
	  let line = display-line-line(dline);
	  display-line(line, mode, window, 0, y + display-line-baseline(dline),
		       start: display-line-start(dline), end: display-line-end(dline),
		       align-y: #"baseline")
	end
      end
    end
  end
end method display-region-marking;

// Compute the marking for each line on the display
// This assumes that all the display lines have been updated
// NB: must be called with the caret hidden
define sealed method update-display-line-marking
    (window :: <basic-window>, #key move-point? = #t) => ()
  block (return)
    when (window-mark(window))
      let buffer :: <basic-buffer> = window-buffer(window);
      let mode    = buffer-major-mode(buffer);
      let frame   = window-frame(window);
      let extend? = (marking-policy(editor-policy(frame-editor(frame))) == #"right-margin");
      let (width, height) = window-size(window);
      ignore(height);
      // Restrict the interval to what is visible on the screen, so
      // that we don't spend lots of time updating what is not visible
      let lines   :: <simple-object-vector> = window-display-lines(window);
      let n-lines :: <integer> = window-n-display-lines(window);
      let (pbp, mbp) = order-bps(window-point(window), window-mark(window));
      let bp1 = if (find-display-line(window, bp-line(pbp)))
		  pbp
		else
		  let line = display-line-line(lines[0]);
		  line-start(line)
		end;
      let bp2 = if (find-display-line(window, bp-line(mbp)))
		  mbp
		else
		  let line = display-line-line(lines[n-lines - 1]);
		  let next = line-next-in-buffer(line, buffer, skip-test: #f);
		  // Ensure that things work correctly when 'extend?' is #t
		  if (next) line-start(next) else line-end(line) end
		end;
      // If the marked region is entirely off the visible part of the
      // display (as can happen when 'scrolling-moves-point?' is true),
      // we can just stop now
      when (~move-point? & (bp-less?(mbp, bp1) | bp-greater?(pbp, bp2)))
	return()
      end;
      let interval = make-interval(bp1, bp2, in-order?: #t);
      let hint :: false-or(<integer>) = #f;
      local method update-marking
		(line :: <basic-line>, si :: <integer>, ei :: <integer>, last?)
	      let (dline, new-hint) = find-display-line(window, line, hint: hint);
	      unless (dline)
		return()				// we must be done
	      end;
	      hint := new-hint;
	      when (dline & ~display-line-mark-x(dline))
		let dline :: <display-line> = dline;	// force tighter type...
		unless (si = display-line-mark-start(dline)
			& ei = display-line-mark-end(dline))
		  let margin = line-margin(line, mode, window);
		  display-line-mark-start(dline) := si;
		  display-line-mark-end(dline)   := ei;
		  display-line-mark-tick(dline)  := $minimum-integer;
		  if (text-line?(line))
		    let x = line-size(line, mode, window, end: si);
		    let w = if (extend? & ~last? & ei = line-length(line)) width
			    else line-size(line, mode, window, start: si, end: ei) end;
		    display-line-mark-x(dline)     := x;
		    display-line-mark-width(dline) := w - margin;
		  else
		    let x = 0;
		    let w = width;
		    display-line-mark-x(dline)     := x + margin;
		    display-line-mark-width(dline) := w
		  end
		end
	      end
	    end method;
      do-lines(update-marking, interval)
    end
  end
end method update-display-line-marking;

// Force recomputation of the visible region marking
// Note that 'move-point!' followed by 'move-mark!' does all this twice,
// which is why clients should be careful not to do this a lot!
define sealed method decache-display-line-marking
    (window :: <basic-window>,
     bp :: <basic-bp>, line :: <basic-line>, index :: <integer>) => ()
  let line1  = bp-line(bp);
  let line2  = line;
  let buffer = window-buffer(window);
  let mode   = buffer-major-mode(buffer);
  block ()
    hide-caret(window, tooltip?: #t);
    if (line1 == line2)
      let dline = find-display-line(window, line);
      when (dline)
	let dline :: <display-line> = dline;		// force tighter type...
	let x = display-line-mark-x(dline);
	// Only clear the marked region if it's getting smaller
	when (x & (index > display-line-mark-start(dline)
		   & index < display-line-mark-end(dline)))
	  let y = display-line-y(dline);
	  let w = display-line-mark-width(dline);
	  let h = display-line-height(dline);
	  clear-area(window, x, y, x + w, y + h);
	  let line = display-line-line(dline);
	  display-line(line, mode, window, 0, y + display-line-baseline(dline),
		       start: display-line-start(dline), end: display-line-end(dline),
		       align-y: #"baseline")
	end;
	display-line-mark-start(dline) := #f;
	display-line-mark-end(dline)   := #f;
	display-line-mark-x(dline)     := #f;
	display-line-mark-width(dline) := #f;
	display-line-mark-tick(dline)  := $minimum-integer
      end
    else
      when (line-less?(buffer, line2, line1))
	swap!(line1, line2)
      end;
      let hint :: false-or(<integer>) = #f;
      block (break)
	for (line = line1 then line-next-in-buffer(line, buffer),
	     until: ~line)
	  let (dline, new-hint) = find-display-line(window, line, hint: hint);
	  if (dline)
	    hint := new-hint;
	    let dline :: <display-line> = dline;		// force tighter type...
	    let x = display-line-mark-x(dline);
	    when (x)
	      let y = display-line-y(dline);
	      let w = display-line-mark-width(dline);
	      let h = display-line-height(dline);
	      clear-area(window, x, y, x + w, y + h);
	      let line = display-line-line(dline);
	      display-line(line, mode, window, 0, y + display-line-baseline(dline),
			   start: display-line-start(dline), end: display-line-end(dline),
			   align-y: #"baseline");
	    end;
	    display-line-mark-start(dline) := #f;
	    display-line-mark-end(dline)   := #f;
	    display-line-mark-x(dline)     := #f;
	    display-line-mark-width(dline) := #f;
	    display-line-mark-tick(dline)  := $minimum-integer
	  else
	    break()					// no dline, we must be done
	  end;
	  when (line == line2)
	    break()
	  end
	end
      end block;
    end;
  cleanup
    show-caret(window, tooltip?: #t)
  end
end method decache-display-line-marking;


/// Bracket matching

define sealed method highlight-matching-thing
    (window :: <basic-window>) => ()
  let mode  = buffer-major-mode(window-buffer(window));
  let table = list-syntax-table(mode);
  let bp    = window-point(window);
  let node  = bp-node(bp) | bp-buffer(bp);
  let (bp, char)
    = case
	character-syntax(bp-character-before(bp), table) == $list-close =>
	  let bp   = move-over-lists(bp, -1, interval: node, fixup?: #f);
	  let char = bp & bp-character(bp);
	  if (char & character-syntax(char, table) == $list-open)
	    values(bp, char)
	  else
	    values(#f, #f)
	  end;
	character-syntax(bp-character(bp), table) == $list-open =>
	  let bp   = move-over-lists(bp,  1, interval: node, fixup?: #f);
	  let bp   = bp & decrement-bp!(bp);
	  let char = bp & bp-character(bp);
	  if (char & character-syntax(char, table) == $list-close)
	    values(bp, char)
	  else
	    values(#f, #f)
	  end;
      end;
  window-matching-bp(window) := bp;
  when (bp)
    let line  = bp-line(bp);
    let index = bp-index(bp);
    let dline = find-display-line(window, line);
    when (dline)
      window-matching-string(window)[0] := char;
      let x = index->position(line, mode, window, index);
      let y = display-line-y(dline);
      let mark?
	= (display-line-mark-x(dline)
	   & index >= display-line-mark-start(dline)
	   & index <  display-line-mark-end(dline));
      let font = window-default-font(window);
      let bold = window-default-bold-font(window);
      let dx   = font-metrics(window, font);
      let dy   = display-line-height(dline);
      draw-rectangle(window, x, y, x + dx, y + dy,
		     color: if (mark?) $region-marking-color else $default-background end,
		     filled?: #t);
      draw-string(window, window-matching-string(window),
		  x, y + display-line-baseline(dline),
		  font: bold, align-y: #"baseline")
    end
  end
end method highlight-matching-thing;

define sealed method unhighlight-matching-thing
    (window :: <basic-window>) => ()
  let bp = window-matching-bp(window);
  window-matching-bp(window) := #f;
  when (bp)
    let line  = bp-line(bp);
    let index = bp-index(bp);
    // Watch out for someone having clobbered the line behind our back...
    when (index <= line-length(line))
      let dline = find-display-line(window, line);
      when (dline)
	window-matching-string(window)[0] := bp-character(bp);
	let mode = buffer-major-mode(window-buffer(window));
	let x    = index->position(line, mode, window, index);
	let y    = display-line-y(dline);
	let mark?
	  = (display-line-mark-x(dline)
	     & index >= display-line-mark-start(dline)
	     & index <  display-line-mark-end(dline));
	let font = window-default-font(window);
	let bold = window-default-bold-font(window);
	let dx   = font-metrics(window, bold);
	let dy   = display-line-height(dline);
	draw-rectangle(window, x, y, x + dx, y + dy,
		       color: if (mark?) $region-marking-color else $default-background end,
		       filled?: #t);
	draw-string(window, window-matching-string(window),
		    x, y + display-line-baseline(dline),
		    font: font, align-y: #"baseline")
      end
    end
  end
end method unhighlight-matching-thing;


/// BP <-> (x,y) mapping

// This assumes that 'window-display-lines' is up to date and that
// the BP is visible on the screen
define sealed method bp->position
    (window :: <basic-window>, bp :: <basic-bp>)
 => (x :: false-or(<integer>), y :: false-or(<integer>))
  let mode  = buffer-major-mode(window-buffer(window));
  let line  = bp-line(bp);
  let index = bp-index(bp);
  let dline = find-display-line(window, line);
  if (dline)
    values(index->position(line, mode, window, index),
	   display-line-y(dline))
  else
    values(#f, #f)
  end
end method bp->position;

define sealed method position->bp
    (window :: <basic-window>, x :: <integer>, y :: <integer>)
 => (bp :: false-or(<basic-bp>), display-line :: false-or(<display-line>))
  let buffer = window-buffer(window);
  when (buffer)
    let dline :: false-or(<display-line>) = #f;
    // First locate the line
    block (break)
      let lines   :: <simple-object-vector> = window-display-lines(window);
      let n-lines :: <integer> = window-n-display-lines(window);
      let last-y = 0;
      without-bounds-checks
	for (i :: <integer> from 0 below n-lines)
	  dline := lines[i];
	  let dy = display-line-y(dline);
	  // Make sure we get some sort of a hit in the inter-line spacing...
	  if (last-y <= y & y <= dy + display-line-height(dline))
	    break()
	  else
	    last-y := dy
	  end
	end
      end
    end block;
    if (dline)
      // Now locate the index within the line
      let mode  = buffer-major-mode(buffer);
      let line  = display-line-line(dline);
      let index = position->index(line, mode, window, x);
      values(make-bp(line, index), dline)
    else
      values(#f, #f)
    end
  end
end method position->bp;


/// Redisplay-related functions

define inline function point () => (bp :: <basic-bp>)
  window-point(frame-window(*editor-frame*))
end function point;

define generic move-point!
    (bp-or-line :: type-union(<bp>, <line>), #key) => ();

define sealed inline method move-point!
    (bp :: <basic-bp>, #key window) => ()
  move-point!(bp-line(bp), index: bp-index(bp), window: window)
end method move-point!;

// Note that neither this nor 'move-mark!' arrange for any redisplay;
// that is supposed to happen at a higher level
define sealed method move-point!
    (line :: <basic-line>, #key index :: <integer> = 0, window) => ()
  let window :: <basic-window> = window | frame-window(*editor-frame*);
  let buffer = window-buffer(window);
  when (buffer)
    let bp = window-point(window);
    if (bp == $null-bp)
      bp := make(<permanent-bp>, line: line, index: index, buffer: buffer);
      window-point(window) := bp
    else
      when (window-mark(window))
        decache-display-line-marking(window, bp, line, index)
      end;
      let section = line-section(bp-line(bp));
      unless (section == line-section(line))
	// If we moved into a new section, resectionize the one
	// we just left
	resectionize-section(section)
      end;
      move-bp!(bp, line, index)
    end
  end
end method move-point!;


define inline function mark () => (bp :: false-or(<basic-bp>))
  window-mark(frame-window(*editor-frame*))
end function mark;

define generic move-mark!
    (bp-or-line :: type-union(<bp>, <line>), #key) => ();

define sealed inline method move-mark!
    (bp :: <basic-bp>, #key window) => ()
  move-mark!(bp-line(bp), index: bp-index(bp), window: window)
end method move-mark!;

define sealed method move-mark!
    (line :: <basic-line>, #key index :: <integer> = 0, window) => ()
  let window :: <basic-window> = window | frame-window(*editor-frame*);
  let buffer = window-buffer(window);
  when (buffer)
    let bp = window-mark(window);
    if (bp)
      decache-display-line-marking(window, bp, line, index);
      move-bp!(bp, line, index)
    else
      bp := make(<permanent-bp>, line: line, index: index, buffer: buffer);
      window-mark(window) := bp;
      window-note-selection-changed(window, bp)
    end;
    window-last-mark(window) := window-mark(window)
  end
end method move-mark!;


define sealed method clear-mark!
    (#key window, redisplay? = #f) => ()
  let window :: <basic-window> = window | frame-window(*editor-frame*);
  let buffer = window-buffer(window);
  when (buffer & window-mark(window))
    window-last-mark(window) := window-mark(window);
    window-mark(window) := #f;
    window-note-selection-changed(window, #f);
    when (redisplay?)
      queue-redisplay(window, $display-region);
      redisplay-window(window)
    end
  end
end method clear-mark!;


// Do this the primitive way to avoid unduly perturbing the display
define sealed method swap-point-and-mark!
    (window :: <basic-window>) => ()
  let point = window-point(window);
  let mark  = window-mark(window);
  let (pl, px) = values(bp-line(point), bp-index(point));
  let (ml, mx) = values(bp-line(mark),  bp-index(mark));
  move-bp!(point, ml, mx);
  move-bp!(mark,  pl, px)
end method swap-point-and-mark!;


/// Default display methods for all kinds of lines

define method position->index
    (line :: <basic-line>, mode :: <major-mode>, window :: <basic-window>,
     x :: <integer>)
 => (index :: <integer>)
  0
end method position->index;

define method index->position
    (line :: <basic-line>, mode :: <major-mode>, window :: <basic-window>,
     index :: <integer>)
 => (x :: <integer>)
  line-size(line, mode, window, end: index)
end method index->position;

define method line-margin
    (line :: <basic-line>, mode :: <major-mode>, window :: <basic-window>)
 => (margin :: <integer>)
  0
end method line-margin;


/// Default display methods for text lines

define method display-line
    (line :: <text-line>, mode :: <major-mode>, window :: <basic-window>,
     x :: <integer>, y :: <integer>,
     #key start: _start :: <integer> = 0, end: _end :: <integer> = line-length(line),
	  align-y = #"top") => ()
  let contents   = line-contents(line);
  let changes    = line-style-changes(line);
  let properties = line-contents-properties(line);
  case 
    ~empty?(changes) =>
      // There are style changes, we have to draw the string the slow way
      //--- For now we ignore colorizing properties, it's just too hairy
      without-bounds-checks
	let index   = _start;
        let default = window-default-font(window);
        let font    = default;
	let color   = $default-foreground;
	// Measure and draw each part of the string
        for (change :: <style-change> in changes)
	  let next-index = style-change-index(change);
	  let next-font  = style-change-font(change) | default;
	  let next-color = style-change-color(change);
	  let _end       = min(_end, next-index);
	  when (index >= _start & index < _end)
	    let width = string-size(window, contents,
				    start: index, end: _end,
				    font: font);
	    draw-string(window, contents, x, y,
			start: index, end: _end,
			font: font, color: color, align-y: align-y);
	    inc!(x, width);
	  end;
	  index := next-index;
	  font  := next-font;
	  color := next-color;
	end;
	// Draw the last part of the string
	draw-string(window, contents, x, y,
		    start: index, end: _end,
		    font: font, color: color, align-y: align-y)
      end;
    ~empty?(properties) =>
      // There's some line-coloring information
      // The coloring information is assumed to partition the line,
      // and be in order sorted by the start indices
      let colors :: <simple-object-vector>
	= get-property(properties, #"colors", default: #[]);
      // First draw the string in the usual color
      draw-string(window, contents, x, y,
		  start: _start, end: _end, align-y: align-y);
      // Now loop over the colored substrings, drawing each in turn
      for (i :: <integer> from 0 below size(colors) by 3)
	let _s    :: <integer> = colors[i + 0];
	let _e    :: <integer> = colors[i + 1];
	let color              = colors[i + 2];
	when (_s < _end | _e > _start)
	  _s := max(_s, _start);
	  _e := min(_e, _end);
	  when (_s < _e)
	    let x = x + string-size(window, contents, start: 0, end: _s);
	    draw-string(window, contents, x, y,
			start: _s, end: _e, color: color, align-y: align-y);
	  end
	end
      end;
    otherwise =>
      // Otherwise just draw a fixed text string
      draw-string(window, contents, x, y,
		  start: _start, end: _end, align-y: align-y);
  end
end method display-line;

define method line-size
    (line :: <text-line>, mode :: <major-mode>, window :: <basic-window>,
     #key start: _start :: <integer> = 0, end: _end :: <integer> = line-length(line))
 => (width :: <integer>, height :: <integer>, baseline :: <integer>)
  let contents = line-contents(line);
  let changes  = line-style-changes(line);
  case
    ((_end - _start) = 0) =>
      // Ensure that blank lines have some height
      let font = window-default-font(window);
      let (width, height, ascent, descent) = font-metrics(window, font);
      ignore(width, descent);
      values(0, height, ascent);
    ~empty?(changes) =>
      // There are style changes, we have to measure the string the slow way
      without-bounds-checks
	let (total-width, max-height, max-baseline) = values(0, 0, 0);
	let index   = _start;
        let default = window-default-font(window);
        let font    = default;
        for (change :: <style-change> in changes)
	  let next-index = style-change-index(change);
	  let next-font  = style-change-font(change) | default;
	  let _end       = min(_end, next-index);
	  when (index >= _start & index < _end)
	    let (width, height, baseline)
	      = string-size(window, contents,
			    start: index, end: _end,
			    font: font);
	    inc!(total-width,   width);
	    max!(max-height,    height);
	    max!(max-baseline,  baseline);
	  end;
	  index := next-index;
	  font  := next-font;
	end;
        let (width, height, baseline)
	  = string-size(window, contents,
			start: index, end: _end,
			font: font);
        inc!(total-width,   width);
        max!(max-height,    height);
        max!(max-baseline,  baseline);
        values(total-width, max-height, max-baseline)
      end;
    otherwise =>
      // Otherwise just measure a fixed text string
      string-size(window, contents,
		  start: _start, end: _end);
  end
end method line-size;

define method position->index
    (line :: <text-line>, mode :: <major-mode>, window :: <basic-window>,
     x :: <integer>)
 => (index :: <integer>)
  if (x < 0)
    0
  else
    let font = window-default-font(window);
    let (width, height, ascent, descent) = font-metrics(window, font);
    ignore(height, ascent, descent);
    // Guess the index as though all the chars in the line have the same width
    // (Note that for fixed text lines, tabs have variable width)
    let length   :: <integer> = line-length(line);
    let index    :: <integer> = min(floor/(x, width), length);
    let margin   :: <integer> = line-margin(line, mode, window);
    let x-fixed  :: <integer> = index * width + margin;
    if (index->position(line, mode, window, index) = x-fixed)
      // It seems that we guessed correctly, so we're done
      min(index, length)
    else
      // There's probably a tab in the line somewhere that is making our
      // life difficult.  Hunt backwards until we find an index that puts
      // us at, or just past, the desired X position
      while (index > 0
	     & index->position(line, mode, window, index) > x + margin)
	dec!(index)
      end;
      min(index, length)
    end
  end
end method position->index;
