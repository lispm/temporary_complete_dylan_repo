Module:    httpi
Synopsis:  Core HTTP server code
Author:    Gail Zacharias, Carl Gay
Copyright: Copyright (c) 2001-2004 Carl L. Gay.  All rights reserved.
           Original Code is Copyright (c) 2001 Functional Objects, Inc.  All rights reserved.
License:   Functional Objects Library Public License Version 1.0
Warranty:  Distributed WITHOUT WARRANTY OF ANY KIND


define constant $http-version = "HTTP/1.1";
define constant $server-name = "Koala";
define constant $server-version = "0.4";


// This may be set true by config file loading code, in which case
// start-server will be a no-op.
define variable *abort-startup?* :: <boolean> = #f;

define constant $server-header-value = concatenate($server-name, "/", $server-version);

// This is needed to handle sockets shutdown.
define variable *exiting-application* = #f;

begin
  register-application-exit-function(method ()
                                       *exiting-application* := #t
                                     end);
end;

define class <server> (<sealed-constructor>)
  constant slot server-lock :: <lock>,
    required-init-keyword: lock:;
  // Support for shutting down listeners.
  constant slot server-listeners :: <stretchy-vector> = make(<stretchy-vector>);
  constant slot server-listeners-notification :: <notification>,
    required-init-keyword: listeners-notification:;
  constant slot clients :: <stretchy-vector> = make(<stretchy-vector>);
  constant slot clients-notification :: <notification>,
    required-init-keyword: clients-notification:;
  constant slot listener-shutdown-timeout :: <real> = 15;
  constant slot client-shutdown-timeout :: <real> = 15;

  // Parameters
  slot max-listeners :: <integer> = 1;
  slot request-class :: subclass(<basic-request>) = <basic-request>;

  //---TODO: response for unsupported-request-method-error MUST include
  // Allow: field...  Need an API for making sure that happens.
  // RFC 2616, 5.1.1

  // Map from URL string to a response function.  The leading slash is removed
  // from URLs because it's easier to use merge-locators that way.
  // TODO: this should be per vhost
  //       then 'define page' needs to specify vhost until dynamic
  //       library loading works.  (ick.)  once dynamic library loading
  //       works we use <module foo> inside <virtual-host> in the config
  //       and bind *virtual-host* while the library is loading?

  constant slot url-map :: <string-trie> = make(<string-trie>, object: #f);

  // pathname translations
  //slot pathname-translations :: <sequence> = #();

  //// Statistics
  // todo -- move these elsewhere

  slot connections-accepted :: <integer> = 0; // Connections accepted
  constant slot user-agent-stats :: <string-table> = make(<string-table>);
  constant class slot startup-date :: <date> = current-date();
end;

define sealed method make
    (c == <server>, #rest keys, #key) => (server :: <server>)
  let lock = make(<lock>);
  let listeners-notification = make(<notification>, lock: lock);
  let clients-notification = make(<notification>, lock: lock);
  apply(next-method, c,
        lock: lock,
        listeners-notification: listeners-notification,
        clients-notification: clients-notification,
        keys)
end make;

// Keep some stats on user-agents
define method note-user-agent
    (server :: <server>, user-agent :: <string>)
  with-lock (server.server-lock)
    let agents = user-agent-stats(server);
    agents[user-agent] := element(agents, user-agent, default: 0) + 1;
  end;
end;

define function release-listener (listener :: <listener>)
  let server = listener.listener-server;
  with-lock (server.server-lock)
    remove!(server.server-listeners, listener);
    when (empty?(server.server-listeners))
      release-all(server.server-listeners-notification);
    end;
  end;
end release-listener;

define function release-client (client :: <client>)
  let server = client.client-server;
  with-lock (server.server-lock)
    remove!(server.clients, client);
    when (empty?(server.clients))
      release-all(server.clients-notification);
    end;
  end;
end release-client;

define class <listener> (<sealed-constructor>)
  constant slot listener-server :: <server>,
    required-init-keyword: server:;
  constant slot listener-port :: <integer>,
    required-init-keyword: port:;
  constant slot listener-host :: false-or(<string>),
    required-init-keyword: host:;
  constant slot listener-thread :: <thread>,
    required-init-keyword: thread:;
  slot listener-socket :: <server-socket>,
    required-init-keyword: socket:;
  // Maybe should hold some mark of who requested it..
  slot listener-exit-requested? :: <boolean> = #f;
  // The time when server entered 'accept', so we can
  // abort it if it's hung...
  slot listener-listen-start :: false-or(<date>) = #f;

  // Statistics
  slot connections-accepted :: <integer> = 0;
  slot total-restarts :: <integer> = 0;             // Listener restarts

end class <listener>;

define class <client> (<sealed-constructor>)
  constant slot client-server :: <server>,
    required-init-keyword: server:;
  constant slot client-listener :: <listener>,
    required-init-keyword: listener:;
  constant slot client-socket :: <tcp-socket>,
    required-init-keyword: socket:;
  constant slot client-thread :: <thread>,
    required-init-keyword: thread:;
  slot client-request :: <basic-request>;
end;

define class <basic-request> (<sealed-constructor>)
  constant slot request-client :: <client>,
    required-init-keyword: client:;
end;

define generic read-request (request :: <basic-request>);
define generic invoke-handler (request :: <basic-request>);

define generic request-keep-alive? (request :: <basic-request>) => (well? :: <boolean>);

define method initialize (request :: <basic-request>, #key, #all-keys)
  next-method();
  request.request-client.client-request := request;
end;

define inline function request-socket (request :: <basic-request>)
    => (socket :: <tcp-socket>)
  request.request-client.client-socket
end;

define inline function request-server (request :: <basic-request>)
    => (server :: <server>)
  request.request-client.client-server
end;

/*
define inline function request-thread (request :: <basic-request>)
    => (server :: <thread>)
  request.request-client.client-thread
end;

define inline function request-port (request :: <basic-request>)
    => (port :: <integer>)
  request.request-client.client-listener.listener-port;
end;
*/

define variable *sockets-started?* :: <boolean> = #f;

define function ensure-sockets-started ()
  unless (*sockets-started?*)
    start-sockets();
    //start-ssl-sockets();
    *sockets-started?* := #t;
  end;
end;

define variable *server* :: <server> = make(<server>);
define variable *server-lock* = make(<lock>); // overkill, but so what.

define function ensure-server () => (server :: <server>)
  with-lock (*server-lock*)
    *server* | (*server* := make(<server>))
  end
end ensure-server;

define function http-server () => (server :: <server>)
  *server*
end;

define variable *next-listener-id* :: <integer> = 0;

// This is called when the library is loaded (from main.dylan).
define function init-server
    (#key listeners :: <integer> = 1,
     request-class :: subclass(<basic-request>)
       = *default-request-class*,
     config-file)
  let server :: <server> = ensure-server();
  server.max-listeners := listeners;
  server.request-class := request-class;
  configure-server(config-file);
  log-info("%s HTTP Server starting up", $server-name);
  ensure-sockets-started();  // TODO: Can this be moved into start-server?
  log-info("Server root directory is %s", *server-root*);
  when (*auto-register-pages?*)
    log-info("Auto-register enabled");
  end;
  run-init-functions();
end init-server;

// API
// This is what client libraries call to start the server.
//
define function start-server
    (#key config-file :: false-or(<string>))
 => (started? :: <boolean>)
  if (~config-file)
    let args = application-arguments();
    let pos = find-key(args, method (x) as-lowercase(x) = "--config" end);
    if (pos & (args.size > pos + 1))
      config-file := args[pos + 1];
    end;
  end if;
  init-server(config-file: config-file);
  if (*abort-startup?*)
    log-error("Server startup aborted due to the previous errors");
    #f
  else
    let ports = #();
    for (vhost keyed-by name in $virtual-hosts)
      ports := add!(ports, vhost-port(vhost))
    end;
    if (*fall-back-to-default-virtual-host?*)
      ports := add!(ports, vhost-port($default-virtual-host));
    end;
    if (empty?(ports))
      log-error("No ports to listen on!  No virtual hosts were specified "
                "in the config file and fallback to the default vhost is "
                "disabled.");
      #f
    else
      // temporary code...
      let port = ports[0];
      let ip = vhost-ip($default-virtual-host);
      while (start-http-listener(*server*, port, ip))
        *server-running?* := #t;
      end;
      // Apparently when the main thread dies in a FunDev Dylan application
      // the application exits without waiting for spawned threads to die,
      // so join-listeners keeps the main thread alive until all listeners die.
      join-listeners(*server*);
      *server-running?* := #f;
      #t
    end if
  end if
end function start-server;

define function join-listeners
    (server :: <server>)
  // Don't use join-thread, because no timeouts, so could hang.
  // eh?
  block (return)
    while (#t)
      sleep(1);
      with-lock (server.server-lock)
        if (empty?(server.server-listeners))
          return();
        end;
      end;
    end;
  end;
end;

// If there's ever a UI, it should have a button to call this.
//
define function stop-server (#key abort)
  let server = *server*;
  when (server)
    abort-listeners(server);
    when (~abort)
      join-clients(server);
    end;
    abort-clients(server);
  end;
end;

define function abort-listeners (server :: <server>)
  iterate next ()
    let listener = with-lock (server.server-lock)
                     any?(method (listener :: <listener>)
                            ~listener.listener-exit-requested? & listener
                          end, server.server-listeners);
                   end;
    when (listener)
      listener.listener-exit-requested? := #t; // don't restart
      synchronize-side-effects();
      close(listener.listener-socket, abort?: #t);
      next();
    end;
  end iterate;
  // Don't use join-thread, because no timeouts, so could hang.
  let n = with-lock (server.server-lock)
            empty?(server.server-listeners) |
              wait-for(server.server-listeners-notification,
                       timeout: server.listener-shutdown-timeout);
            let n = server.server-listeners.size;
            server.server-listeners.size := 0;
            n
          end;
  when (n > 0)
    log-warning("Listeners shutdown timed out, %d left", n);
  end;
end abort-listeners;

// At this point all listeners have been shut down, so shouldn't
// be spawning any more clients.
define function abort-clients (server :: <server>, #key abort)
  with-lock (server.server-lock)
    for (client in server.clients)
      close(client.client-socket, abort: abort);
    end;
  end;
  let n = join-clients(server, timeout: server.client-shutdown-timeout);
  when (n > 0)
    log-warning("Clients shutdown timed out, %d left", n);
  end;
end abort-clients;

define function join-clients (server :: <server>, #key timeout)
  => (clients-left :: <integer>)
  with-lock (server.server-lock)
    empty?(server.clients)
      | wait-for(server.clients-notification, timeout: timeout);
    let n = server.clients.size;
    server.clients.size := 0;
    n
  end;
end join-clients;

define function start-http-listener (server :: <server>, port :: <integer>, ip :: <string>)
   => (started? :: <boolean>)
  let server-lock = server.server-lock;
  let listener = #f;
  local method run-listener-top-level ()
          with-lock (server-lock) end; // Wait for setup to finish.
          //---TODO: Include the thread name in the log message.
          log-info("Listener starting up");
          let listener :: <listener> = listener;
          block ()
            listener-top-level(listener);
          cleanup
            log-info("Listener on port %d shutting down", port);
            close(listener.listener-socket, abort?: #t);
            release-listener(listener);
          end;
        end method;
  let started? = #f;
  with-lock (server-lock)
    let listeners = server.server-listeners;
    when (listeners.size < server.max-listeners)
      log-debug("Creating a new listener thread.");
      let socket = make(<server-socket>, host: ip, port: port);
      let thread = make(<thread>,
                        name: format-to-string("HTTP Listener #%s/%d", *next-listener-id*, port),
                        function: run-listener-top-level);
      wrapping-inc!(*next-listener-id*);
      listener := make(<listener>,
                       server: server,
                       port: port,
                       socket: socket,
                       host: ip,
                       thread: thread);
      add!(server.server-listeners, listener);
      started? := #t
    end;
  end;
  started?
end start-http-listener;

define function listener-top-level (listener :: <listener>)
  with-socket-thread (server?: #t)
    // loop spawning clients until listener socket gets broken.
    do-http-listen(listener);
  end;
  // Kill or reuse thread
  let server = listener.listener-server;
  let restart? = with-lock (server.server-lock)
                   let listeners = server.server-listeners;
                   when (*exiting-application*)
                     server.max-listeners := 0
                   end;
                   when (~*exiting-application* &
                         ~listener.listener-exit-requested? &
                         listeners.size <= server.max-listeners)
                     listener.listener-socket
                       := make(<server-socket>,
                               host: listener.listener-host,
                               port: listener.listener-port);
                     inc!(listener.total-restarts);
                     #t
                   end;
                 end;
  let name = listener.listener-thread.thread-name;
  if (restart?)
    log-info("Restarting %s", name);
    listener-top-level(listener);
  else
    log-info("Shutting down %s", name);
  end;
end listener-top-level;

//---TODO: need to set up timeouts.
//---TODO: need to limit the number of outstanding clients.
//---TODO: need to be able to stop the server from outside.
// Can't do anything to the thread, but can do things to the server socket
// so that it will return from 'accept' with some error, which we should
// catch gracefully..
//---TODO: need to handle errors.
// Listen and spawn handlers until listener socket breaks.
//
define function do-http-listen (listener :: <listener>)
  let server = listener.listener-server;
  let server-lock = server.server-lock;
  iterate loop ()
    // Let outsiders know when we've blocked...
    listener.listener-listen-start := current-date();
    let socket = block ()
                   unless (listener.listener-exit-requested?)
                     log-info("Ready for service on port %d",
                              listener.listener-port);
                     // use "element-type: <byte>" here?
                     accept(listener.listener-socket); // blocks
                   end;
                 exception (c :: <socket-condition>)
                   log-error("%=", c);
                   #f
                 end;
    synchronize-side-effects();
    listener.listener-listen-start := #f;
    when (socket)
      //---TODO: should limit number of clients.
      let client = #f;
      local method do-respond ()
              with-lock (server-lock) end;   // Wait for setup to finish.
              let client :: <client> = client;
              block ()
                with-socket-thread ()
                  handler-top-level(client);
                end;
              cleanup
                ignore-errors(<socket-condition>,
                              close(client.client-socket, abort: #t));
                release-client(client);
              end;
            end method;
      with-lock (server-lock)
        block()
          wrapping-inc!(listener.connections-accepted);
          wrapping-inc!(server.connections-accepted);
          let thread = make(<thread>, name: "HTTP Responder",
                            function:  do-respond);
          client := make(<client>,
                         server: server,
                         listener: listener,
                         socket: socket,
                         thread: thread);
          add!(server.clients, client);
        exception (e :: <error>)
          //this should be <thread-error>, which is not yet exported
          //needs a compiler bootstrap, so specify it sometime later
          //hannes, 27th January 2007
          log-info("Thread error %=", e)
        end;
      end;
      loop();
    end when;
  end iterate;
  close(listener.listener-socket, abort: #t);
end do-http-listen;

define class <request> (<basic-request>)
  slot request-method :: <symbol> = #"unknown";
  slot request-version :: <symbol> = #"unknown";
  slot request-url :: <string> = "";

  // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.2
  slot request-host :: false-or(<string>) = #f;

  slot request-keep-alive? :: <boolean> = #f;

  // The actual headers, mapping string -> raw data
  // (The header names are not interned to avoid permanent wedgedness
  //  by invalid headers).
  slot request-headers :: <header-table> = make(<header-table>);

  // Cache, mapping keyword (requested by user) -> parsed data
  constant slot request-header-values :: <object-table> = make(<object-table>);

  slot request-query-string :: <string> = "";

  // Query values from either the URL or the body of the POST, if Content-Type
  // is application/x-www-form-urlencoded.
  constant slot request-query-values :: <string-table> = make(<string-table>);

  slot request-session :: false-or(<session>) = #f;

  // The body content of the request.  Only present for POST?
  slot request-content :: <string> = "";

  slot request-responder :: false-or(<function>) = #f;

  // For directory responders, this contains the part of the URL after
  // the matched directory prefix and before the ? (if any).
  slot request-url-tail :: <string> = "";

end class <request>;

define method get-header
    (request :: <request>, name :: <string>) => (header :: <object>)
  element(request.request-headers, name, default: #f)
end;

define variable *default-request-class* :: subclass(<basic-request>) = <request>;

define thread variable *request* :: false-or(<request>) = #f;
define thread variable *response* :: false-or(<response>) = #f;

// Holds the map of query keys/vals in the "?x=1&y=2" part of the URL (for GET method)
// or form keys/vals for the POST method.
define thread variable *request-query-values* :: <string-table>
  = make(<string-table>);

define inline function current-request  () => (request :: <request>) *request* end;
define inline function current-response () => (response :: <response>) *response* end;

// Called (in a new thread) each time an HTTP request is received.
define function handler-top-level
    (client :: <client>)
  dynamic-bind (*request* = #f)
    block (exit-request-handler)
      while (#t)                      // keep alive loop
        let request :: <basic-request>
          = make(client.client-server.request-class, client: client);
        *request* := request;
        with-simple-restart("Skip this request and continue with the next")
          block (exit-inner)
            let handler <error>
              = method (c :: <error>, next-handler :: <function>)
                  if (*debugging-server*)
                    next-handler();  // decline to handle the error
                  else
                    send-error-response(request, c);
                    exit-inner();
                  end;
                end;
            let handler <stream-error>
              = method (c :: <error>, next-handler :: <function>)
                  if (*debugging-server*)
                    next-handler();  // decline to handle the error
                  else
                    log-error("A stream error occurred. %=", c);
                    exit-inner();
                  end;
                end;
                  
            block ()
              block ()
                read-request(request);
                dynamic-bind (*request-query-values* = request.request-query-values,
                              *virtual-host* = virtual-host(request))
                  log-debug("Virtual host for request is '%s'", 
                            vhost-name(*virtual-host*));
                  invoke-handler(request);
                end;
                force-output(request.request-socket);
              exception (c :: <http-error>)
                // Always handle HTTP errors, even when debugging...
                send-error-response(request, c);
                exit-inner();
              end;
            exception (c :: <socket-condition>)
              // Always exit the request handler when a socket error occurs...
              log-debug("A socket error occurred: %s",
                        condition-to-string(c));
              exit-request-handler();
            end;
          end block;
          request.request-keep-alive? | exit-request-handler();
        end with-simple-restart;
      end while;
    end block;
  end dynamic-bind;
end handler-top-level;

// This method takes care of parsing the request headers and signalling any
// errors therein.
//---TODO: have overall timeout for header reading.
define method read-request (request :: <request>) => ()
  let socket = request.request-socket;
  let server = request.request-server;
  let (buffer, len) = read-request-line(socket);
  when (empty-line?(buffer, len))
    // RFC 2616, 4.1 - Servers SHOULD ignore an empty line if received before any headers.
    pset (buffer, len) read-request-line(socket) end;
  end;
  log-info("%s", substring(buffer, 0, len));
  read-request-first-line(request, buffer, len);
  unless (request.request-version == #"http/0.9")
    request.request-headers
      := read-message-headers(socket,
                              buffer: buffer,
                              start: len,
                              headers: request.request-headers);
  end;
  process-incoming-headers(request);
  if (request.request-method == #"post" |
      request.request-method == #"put")
    read-request-content(request);
  end;
end read-request;


// Read first line of the HTTP request.  RFC 2068 Section 5.1
//
//   Request-Line   = Method SP Request-URI SP HTTP-Version CRLF
//
// ---TODO: this code would be a lot clearer if it used regular expressions.
//
define function read-request-first-line
    (request :: <request>, buffer :: <string>, eol :: <integer>)
 => ()
  let method-end = whitespace-position(buffer, 0, eol) | eol;
  if (zero?(method-end))
    invalid-request-line-error();
  else
    request.request-method
      := as(<symbol>, copy-sequence(buffer, start: 0, end: method-end));
    let bpos = skip-whitespace(buffer, method-end, eol);
    let epos = whitespace-position(buffer, bpos, eol) | eol;
    when (epos > bpos)
      let qpos = char-position('?', buffer, bpos, epos);
      
      if (looking-at?("http://", buffer, bpos, qpos | epos))
        // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.2
        // Absolute URLs in the request line take precedence over Host header.
        bpos := bpos + 7;
        let host-end = char-position('/', buffer, bpos, qpos | epos);
        request.request-host := substring(buffer, bpos, host-end | epos);
        bpos := host-end;
      end if;
      if (epos > bpos)
        // Should this trim trailing whitespace???
        request.request-url := substring(buffer, bpos, qpos | epos);
        let (resp, prefix?, tail) = find-responder(request.request-url);
        // If there's a tail (i.e., we didn't match the entire url) and
        // this isn't a directory responder, then no responder was found.
        if (~tail | prefix?)
          request.request-responder := resp;
        end;
        if (tail)
          request.request-url-tail := join(tail, "/");
          log-debug("Setting request-url-tail to %=", request.request-url-tail);
        end;
        if (qpos)
          request.request-query-string := copy-sequence(buffer, start: qpos + 1, end: epos);
          log-debug("Request query string = %s", request.request-query-string);
          extract-query-values(buffer, qpos + 1, epos,
                               request.request-query-values)
        end;
        let bpos = skip-whitespace(buffer, epos, eol);
        let vpos = whitespace-position(buffer, bpos, eol) | eol;
        request.request-version := extract-request-version(buffer, bpos, vpos);
      end if;
    end;
  end;
end;

define function read-request-content
    (request :: <request>)
 => (content :: <byte-string>)
  // ---TODO: Should probably try to continue here even if Content-Length
  //          not supplied.  Or have a "strict" option.
  let content-length
    = request-header-value(request, #"content-length")
      | content-length-required-error();
  if (*max-post-size* & content-length > *max-post-size*)
    //---TODO: the server MAY close the connection to prevent the client from
    // continuing the request.
    request-entity-too-large-error(max-size: *max-post-size*);
  else
    let buffer :: <byte-string> = make(<byte-string>, size: content-length);
    let n = kludge-read-into!(request-socket(request), content-length, buffer);
    assert(n == content-length, "Unexpected incomplete read");
    request-content(request)
      := process-request-content(request-content-type(request), request, buffer, content-length);
  end
end read-request-content;

define inline function request-content-type (request :: <request>)
  let content-type-header = get-header(request, "content-type");
  as(<symbol>,
     if (content-type-header)
       first(split(content-type-header, separator: ";"))
     else
       ""
     end if)
end;

// Gary, in the trunk sources (1) below should now be fixed.  (read was passing the
// wrong arguments to next-method).
// (2) should also be fixed.  It used to cause "Dylan error: 35 is not of type {<class>: <sequence>}"
// But, if you pass on-end-of-stream: #"blah" and then arrange to close the stream somehow
// you'll get an invalid return type error.
// Uncomment either (1) or (2) and comment out the "let n ..." and "assert..." below and
// then start koala example, go to http://localhost:7020/foo/bar/form.html and
// click the Submit button.  As long as neither of these gets an error in the trunk
// build we're better off than before at least, if not 100% fixed.

//let buffer :: <sequence> = read-n(socket, sz, on-end-of-stream: #f);  // (1)
//let n = read-into!(socket, sz, buffer, start: len);                 // (2)
// The following compensates for a bug in read and read-into! in FD 2.0.1

define function kludge-read-into!
    (stream :: <stream>, n :: <integer>, buffer :: <byte-string>,
     #key start :: <integer> = 0)
 => (n :: <integer>)
  block (return)
    for (i from start below buffer.size,
         count from 0 below n)
      let elem = read-element(stream, on-end-of-stream: #f);
      buffer[i] := (elem | return(count));
    end;
    n
  end;
end;

define open generic process-request-content
    (content-type :: <symbol>,
     request :: <request>,
     buffer :: <byte-string>,
     content-length :: <integer>)
 => (content :: <string>);

define method process-request-content
    (content-type :: <symbol>,
     request :: <request>,
     buffer :: <byte-string>,
     content-length :: <integer>)
 => (content :: <string>)
  unsupported-media-type-error()
end;

define method process-request-content
    (content-type == #"application/x-www-form-urlencoded", request :: <request>,
     buffer :: <byte-string>, content-length :: <integer>)
 => (content :: <string>)
  log-debug("Form query string = %=",
            copy-sequence(buffer, end: content-length));
  let content = decode-url(buffer, 0, content-length);
  // By the time we get here request-query-values has already been bound to a <string-table>
  // containing the URL query values.  Now we augment it with any form values.
  extract-query-values(buffer, 0, content-length,
                       request.request-query-values);
  request-content(request) := content
  // ---TODO: Deal with content types intelligently.  For now this'll have to do.
end;

define method process-request-content
    (content-type :: one-of(#"text/xml", #"text/html", #"text/plain"),
     request :: <request>,
     buffer :: <byte-string>,
     content-length :: <integer>)
 => (content :: <string>)
  request-content(request) := buffer
end;

define method process-request-content
    (content-type == #"multipart/form-data", request :: <request>,
     buffer :: <byte-string>, content-length :: <integer>)
 => (content :: <string>)
  let header-content-type = split(get-header(request, "content-type"), separator: ";");
  let boundary = split(second(header-content-type), separator: "=");
  if (element(boundary, 1, default: #f))
    let boundary-value = second(boundary);
    log-debug("boundary: %=", boundary-value);
    extract-form-data(buffer, boundary-value, request);
    // ???
    request-content(request) := buffer
  else
    log-error("%=", "content-type is missing the boundary parameter");
    unsupported-media-type-error();
  end if;
end;

define function send-error-response (request :: <request>, c :: <condition>)
  block ()
    send-error-response-internal(request, c);
  exception (e :: <condition>)
    log-error("An error occurred while sending error response. %=", e);
  end;
end;

define method send-error-response-internal (request :: <request>, err :: <error>)
  let headers = http-error-headers(err) | make(<header-table>);
  let response = make(<response>, request: request, headers: headers);
  let one-liner = http-error-message-no-code(err);
  unless (request-method(request) == #"head")
    let out = output-stream(response);
    set-content-type(response, "text/plain");
    write(out, condition-to-string(err));
    write(out, "\r\n");
  end unless;
  response.response-code    := http-error-code(err);
  response.response-message := one-liner;
  send-response(response);
end method;

// Do whatever we need to do depending on the incoming headers for
// this request.  e.g., handle "Connection: Keep-alive", store
// "User-agent" statistics, etc.
//
define method process-incoming-headers (request :: <request>)
  bind (conn-values :: <sequence> = request-header-value(request, #"connection") | #())
    if (member?("Close", conn-values, test: string-equal?))
      request-keep-alive?(request) := #f
    elseif (member?("Keep-Alive", conn-values, test: string-equal?))
      request-keep-alive?(request) := #t
    end;
  end;
  bind (host = get-header(request, "Host"))
    if (~host & request.request-version == #"HTTP/1.1")
      // HTTP/1.1 requests MUST include a Host header.
      // http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.6.1.1
      bad-request(message: "HTTP/1.1 requests must include a Host header.");
    end;
    // If request host is already set then there was an absolute URL in the request
    // line, which takes precedence, so ignore Host header here.
    // See http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.2
    if (host & ~request.request-host)
      request.request-host := host;
      log-debug("Request host is '%s'", request.request-host);
    end;
  end;
  bind (agent = request-header-value(request, #"user-agent"))
    agent
      & note-user-agent(request-server(request), agent);
  end;
end;

// API
// Register a response function for a given URL.  See find-responder.
define method register-url
    (url :: <string>, target :: <function>, #key replace?, prefix?)
 => ()
  local method reg-url ()
          register-url-now(url, target, replace?: replace?, prefix?: prefix?);
        end;
  if (*server-running?*)
    reg-url();
  else
    register-init-function(reg-url);
  end;
end method register-url;

define method register-url-now
    (url :: <string>, target :: <function>, #key replace?, prefix?)
  let server :: <server> = *server*;
  let (bpos, epos) = trim-whitespace(url, 0, size(url));
  if (bpos = epos)
    error(make(<koala-api-error>,
               format-string: "You cannot register an empty URL: %=",
               format-arguments: list(substring(url, bpos, epos))));
  else
    add-object(server.url-map, url, pair(target, prefix?), replace?: replace?);
  end;
  log-info("URL %s%s registered", url, if (prefix?) "/*" else "" end);
end method register-url-now;

// Find a responder function, if any.
define method find-responder
    (url :: <string>)
 => (responder :: false-or(<function>), #rest more)
  local method maybe-auto-register (url)
          when (*auto-register-pages?*)
            // could use safe-locator-from-url, but it's relatively expensive
            let len = size(url);
            let slash = char-position-from-end('/', url, 0, len);
            let dot = char-position-from-end('.', url, slash | 0, len);
            when (dot & dot < len - 1)
              let ext = substring(url, dot + 1, len);
              let reg-fun = element(*auto-register-map*, ext, default: #f);
              reg-fun & reg-fun(url)
            end
          end
        end;
  let url = decode-url(url, 0, size(url));
  let path = split(url, separator: "/");
  let trie = url-map(*server*);
  let (responder, rest) = find-object(trie, path);
  if (responder)
    let fun = head(responder);
    let prefix? = tail(responder);
    values(fun, prefix?, rest)
  else
    maybe-auto-register(url)
  end
end find-responder;

define open generic remove-responder (object :: <object>);

define method remove-responder (url :: <string>)
  remove-object(*server*.url-map, url)
end;

// Register a function that will attempt to register a responder for a URL
// if the URL matches the file extension.  The function should normally call
// register-url (or register-page for DSPs) and should return a responder.
//
define function register-auto-responder
    (file-extension :: <string>, f :: <function>, #key replace? :: <boolean>)
  if (~replace? & element(*auto-register-map*, file-extension, default: #f))
    cerror("Replace the old auto-responder with the new one and continue.",
           "An auto-responder is already defined for file extension %=.",
           file-extension);
  end;
  *auto-register-map*[file-extension] := f;
end;

// define responder test ("/test" /* , secure?: #t */ )
//     (request, response)
//   format(output-stream(response), "<html><body>test</body></html>");
// end;
define macro responder-definer
  { define responder ?:name (?url:expression)
      ?:body
    end
  }
  => { define method ?name () ?body end;
         register-url(?url, ?name)
     }

  { define directory responder ?:name (?url:expression)
      ?:body
    end
  }
  => { define method ?name () ?body end;
         register-url(?url, ?name, prefix?: #t)
     }
end;

// Invoke the appropriate handler for the given request URL and method.
// Have to buffer up the entire response since the web app needs a chance to
// set headers, etc.  And if the web app signals an error we need to catch it
// and generate the appropriate error response.
define method invoke-handler
    (request :: <request>) => ()
  let headers = make(<header-table>);
  let response = make(<response>,
                      request: request,
                      headers: headers);
  if(request.request-keep-alive?)
    add-header(response, "Connection", "Keep-Alive");
  end if;
  dynamic-bind (*response* = response)
    if (request.request-responder)
      log-debug("%s handler found", request-url(request));
      request.request-responder();
    else
      // generates 404 if not found
      maybe-serve-static-file();
    end;
  end;
  send-response(response);
end invoke-handler;

// Read a line of input from the stream, dealing with CRLF correctly.
//
define function read-request-line
    (stream :: <stream>) => (buffer :: <byte-string>, len :: <integer>)
  let buffer = grow-header-buffer("", 0);
  iterate loop (buffer :: <byte-string> = buffer,
                len :: <integer> = buffer.size,
                pos :: <integer> = 0,
                peek-ch :: false-or(<character>) = #f)
    if (pos == len)
      let buffer = grow-header-buffer(buffer, len);
      loop(buffer, buffer.size, pos, peek-ch)
    else
      let ch :: <byte-character> = peek-ch | read-element(stream);
      if (ch == $cr)
        let ch = read-element(stream);
        if (ch == $lf)
          values(buffer, pos)
        else
          buffer[pos] := $cr;
          loop(buffer, len, pos + 1, ch)
        end;
      else
        buffer[pos] := ch;
        loop(buffer, len, pos + 1, #f)
      end if;
    end;
  end iterate;
end read-request-line;

define inline function empty-line?
    (buffer :: <byte-string>, len :: <integer>) => (empty? :: <boolean>)
  len == 1 & buffer[0] == $cr
end;

define function extract-request-version (buffer :: <string>,
                                         bpos :: <integer>,
                                         epos :: <integer>)
  if (bpos == epos)
    #"HTTP/0.9"
  elseif (string-match("HTTP/1.0", buffer, bpos, epos))
    #"HTTP/1.0"
  elseif (string-match("HTTP/1.1", buffer, bpos, epos))
    #"HTTP/1.1"
  else
    unsupported-http-version-error()
  end;
end extract-request-version;

define class <http-file> (<object>)
  slot http-file-filename :: <string>,
    required-init-keyword: filename:;
  slot http-file-content :: <byte-string>,
    required-init-keyword: content:;
  slot http-file-mime-type :: <string>,
    required-init-keyword: mime-type:;
end;

define method extract-form-data
 (buffer :: <string>, boundary :: <string>, request :: <request>)
  // strip everything after end-boundary
  let buffer = first(split(buffer, separator: concatenate("--", boundary, "--")));
  let parts = split(buffer, separator: concatenate("--", boundary));
  for (part in parts) 
    let part = split(part, separator: "\r\n\r\n");
    let header-entries = split(first(part), separator: "\r\n");
    let disposition = #f;
    let name = #f;
    let type = #f;
    let filename = #f;
    for (header-entry in header-entries)
      let header-entry-parts = split(header-entry, separator: ";");
      for (header-entry-part in header-entry-parts)
        let eq-pos = char-position('=', header-entry-part, 0, size(header-entry-part));
        let p-pos = char-position(':', header-entry-part, 0, size(header-entry-part));
        if (p-pos & (substring(header-entry-part, 0, p-pos) = "Content-Disposition"))
          disposition := substring(header-entry-part, p-pos + 2, size(header-entry-part));
        elseif (p-pos & (substring(header-entry-part, 0, p-pos) = "Content-Type"))
          type := substring(header-entry-part, p-pos + 2, size(header-entry-part));
        elseif (eq-pos & (substring(header-entry-part, 0, eq-pos) = "name"))
          // name unquoted
          name := substring(header-entry-part, eq-pos + 2, size(header-entry-part) - 1);
        elseif (eq-pos & (substring(header-entry-part, 0, eq-pos) = "filename"))
          // filename unquoted
          filename := substring(header-entry-part, eq-pos + 2, size(header-entry-part) - 1);
        end if;
      end for;
    end for;
    if (part.size > 1)
      // TODO: handle disposition = "multipart/form-data" and parse that again
      //disposition = "multipart/form-data" => ...
      if (disposition = "form-data")
        let content = substring(second(part), 0, size(second(part)) - 1);
        request.request-query-values[name]
          := if (filename & type)
               make(<http-file>, filename: filename, content: content, mime-type: type);
             else
               content;
             end if;
      end if;
    end if;
    log-debug("multipart/form-data for %=: %=, %=, %=", name, disposition, type, filename);
  end for;
end method extract-form-data;

// Turn a string like "foo=8&bar=&baz=zzz" into a <string-table> with the "obvious" keys/vals.
// Note that in the above example string "bar" maps to "", not #f.
//---TODO: Find out if the query keys are case-sensitive in the HTTP spec and make sure this
//         does the right thing.
define method extract-query-values
    (buffer :: <string>, bpos :: <integer>, epos :: <integer>, queries :: <string-table>)
 => (queries :: <string-table>)
  local method extract-key/val (beg :: <integer>, fin :: <integer>)
          let eq-pos = char-position('=', buffer, beg, fin);
          if (eq-pos & (eq-pos > beg))
            let key = decode-url(buffer, beg, eq-pos);
            let val = decode-url(buffer, eq-pos + 1, fin);
            values(key, val)
          else
            values(decode-url(buffer, beg, fin), #t)
          end if;
        end;
  local method insert-key/val (key :: <string>, val :: type-union(<string>, <boolean>))
          let hashtable-value = element(queries, key, default: #f);
          if (hashtable-value)
            //for multiple selection option boxes, arguments are passed this way:
            // "foo=2&foo=3&foo=4", that's why we first do a lookup in the hash-table
            // and generate a <stretchy-vector> on the fly -- hannes, 17.11.2007
            if (instance?(hashtable-value, <string>))
              let vec = make(<stretchy-vector>);
              add!(vec, hashtable-value);
              add!(vec, val);
              queries[key] := vec;
            else
              add!(hashtable-value, val);
            end;
          else
            queries[key] := val;
          end;
        end;
  iterate loop (start :: <integer> = bpos)
    when (start < epos)
      let _end = char-position('&', buffer, start, epos) | epos;
      let (key, val) = extract-key/val(start, _end);
      when (key & val)
        insert-key/val(key, val);
      end;
      loop(_end + 1);
    end;
  end;
  queries
end extract-query-values;

define method get-query-value
    (key :: <string>, #key as: as-type :: false-or(<type>)) => (val :: <object>)
  let value = element(*request-query-values*, key, default: #f);
  iff (as-type & value,
       as(as-type, value),
       value)
end;

define method count-query-values
    () => (n :: <integer>)
  size(*request-query-values*)
end;

define method do-query-values
    (f :: <function>)
  for (val keyed-by key in *request-query-values*)
    f(key, val);
  end;
end;

// Is there any need to maintain POSTed values separately from GET query values?
// Don't think so, so this should be ok.
define constant get-form-value :: <function> = get-query-value;
define constant do-form-values :: <function> = do-query-values;
define constant count-form-values :: <function> = count-query-values;


/// Modules

define constant $module-map :: <table> = make(<string-table>);
define constant $module-directory :: <string> = "modules";

// Modules are loaded from <server-root>/modules.
//
define function module-pathname
    (module-name :: <string>) => (path :: <string>)
  as(<string>,
     merge-locators(as(<file-locator>,
                       format-to-string("%s/%s", $module-directory, module-name)),
                    *server-root*))
end;

define function load-module
    (module-name :: <string>)
  let path = module-pathname(module-name);
  log-info("Loading module '%s' from %s...", module-name, path);
  // Note that the linux definition of load-library does nothing right now.
  // -cgay 2004.05.06
  let handle = load-library(path);
  $module-map[module-name] := handle;
end;

define function unload-module
    (module-name :: <string>)
  /*
   * unload-library isn't implemented yet in the operating-system module,
   * and since there's no real need for this method I'm commenting it out
   * for now.  -cgay 2004.05.06
  let handle = element($module-map, module-name, default: #f);
  if (handle)
    log-info("Unloading module %s...", module-name);
    FreeLibrary(handle);
  else
    log-info("Couldn't unload module '%s'.  Module not found.", module-name);
  end;
   */
  log-warning("Unloading modules is not yet implemented.");
end;
