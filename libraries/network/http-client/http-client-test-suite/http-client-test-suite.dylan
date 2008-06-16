module: http-client-test-suite

define variable *http-server-port* :: <integer> = 8080;

define variable *url-prefix* :: <byte-string> = "/http-test";

// Make a full URL for making HTTP requests.
define function full-url
    (url :: <string>, #key secure = #f) => (url :: <string>)
  format-to-string("http://localhost:%d%s",
                   *http-server-port*, short-url(url))
end;

// Make URLs for registering with the server (i.e., just a path)
define function short-url
    (url :: <string>) => (url :: <string>)
  format-to-string("%s%s", *url-prefix*, url)
end;

define suite http-client-test-suite ()
  test test-simple-http-get;
end suite http-client-test-suite;

define responder hello (short-url("/hello"))
  output("hello")
end;

define test test-simple-http-get ()
  check-equal("GET of /hello returns \"hello\"?",
              simple-http-get(full-url("/hello")),
              "hello");
end test test-simple-http-get;

define function main ()
  let parser = make(<argument-list-parser>);
  add-option-parser-by-type(parser,
                            <parameter-option-parser>,
                            description: "Document root for the HTTP client test pages",
                            long-options: #("document-root"),
                            short-options: #("d"));
  add-option-parser-by-type(parser,
                            <parameter-option-parser>,
                            description: "Server port number",
                            long-options: #("port"),
                            short-options: #("p"));
  add-option-parser-by-type(parser,
                            <simple-option-parser>,
                            description: "Display this help message",
                            long-options: #("help"),
                            short-options: #("h"));
  add-option-parser-by-type(parser,
                            <simple-option-parser>,
                            description: "Enable debugging.  Causes Koala to not handle "
                                         "most errors during request handling.",
                            long-options: #("debug"));

  parse-arguments(parser, application-arguments());
  if (option-value-by-long-name(parser, "help")
        | ~empty?(parser.regular-arguments))
    print-synopsis(parser,
                   *standard-output*,
                   usage: format-to-string("%s [options]", application-name()),
                   description: application-name());
  else
    let port = string-to-integer(option-value-by-long-name(parser, "port") | "8080");
    let docroot = option-value-by-long-name(parser, "document-root")
                    // Change default to /var/www/http-test or something
                    | "c:/cgay/dylan/trunk/libraries/network/http-client/tests/www";
    let http-server = make(<http-server>,
                           document-root: docroot);
    // The following shouldn't return until ready for service.
    start-server(http-server,
                 port: port,
                 background: #t,
                 debug: option-value-by-long-name(parser, "debug"));
    // The above returns immediately (for now), so give it time to start up.
    sleep(2);
    run-test-application(http-client-test-suite);
    stop-server(http-server);
  end;
end function main;

begin
  main();
end;
