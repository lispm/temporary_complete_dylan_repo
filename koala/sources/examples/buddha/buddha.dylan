module: buddha
author: Hannes Mehnert <hannes@mehnert.org>

define variable *config* = make(<config>,
                                name: "config",
                                vlans: make(<table>));

define variable *directory* = "www/buddha/";

define sideways method process-config-element
    (node :: <xml-element>, name == #"buddha")
  let cdir = get-attr(node, #"content-directory");
  if (~cdir)
    log-warning("Buddha - No content-directory specified! - will use ./buddha/");
    cdir := "./buddha/";
  end;
  *directory* := cdir;
  log-info("Buddha content directory = %s", *directory*);
end;

define macro page-definer
  { define page ?:name end }
    => { define responder ?name ## "-responder" ("/" ## ?"name")
           (request, response)
           if (request.request-method = #"get")
             respond-to-get(as(<symbol>, ?"name"), request, response)
           elseif (request.request-method = #"post")
             if (respond-to-post(as(<symbol>, ?"name"), request, response))
               respond-to-get(as(<symbol>, ?"name"), request, response)
             end;
           end;
         end; }
end;

define responder default-responder ("/")
  (request, response)
  respond-to-get(#"net", request, response);
end;

define page net end;
define page vlan end;
define page host end;
define page zone end;
define page user end;
define page save end;
define page restore end;
define page browse end;



define macro with-buddha-template
  { with-buddha-template(?stream:variable, ?title:expression)
      ?body:*
    end }
    => { begin
           let page = with-xml-builder()
html(xmlns => "http://www.w3.org/1999/xhtml") {
  head {
    title(concatenate("Buddha - ", ?title)),
    link(rel => "stylesheet", href => "/buddha.css")
  },
  body {
    div(id => "header") {
      div(id => "navbar") {
        a("Network", href => "/net"),
        a("VLAN", href => "/vlan"),
        a("Host", href => "/host"),
        a("Zone", href => "/zone"),
        a("User interface", href => "/user"),
        a("Save to disk", href => "/save"),
        a("Restore from disk", href => "/restore"),
        a("Class browser", href => "/browse"),
        a("Shutdown", href => "/koala/shutdown")
      }
    },
    do(?body)
  }
}
end;
           format(?stream, "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n");
           format(?stream, "%=", page);
         end; }
end;

define constant $obj-table = make(<string-table>);

define method respond-to-get
    (page == #"browse", request :: <request>, response :: <response>)
  let out = output-stream(response);
  let obj-string = get-query-value("obj");
  unless (obj-string)
    obj-string := "";
  end;
  let obj = element($obj-table, obj-string, default: *config*);
  with-buddha-template(out, "Browse")
    with-xml()
      div(id => "content") {
        do(browse(obj))
      }
    end;
  end;
end;

define method respond-to-get
    (page == #"save", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "Save Database")
    with-xml()
      div(id => "content") {
        form(action => "/save", \method => "post") {
          div(class => "edit") {
            text("Filename"),
            input(type => "text", name => "filename"),
            input(type => "submit", name => "save-button", value => "Save")
          }
        }
      }
    end;
  end;
end;

define method respond-to-post
    (page == #"save", request :: <request>, response :: <response>)
  let file = get-query-value("filename");
  let dood = make(<dood>,
                  locator: concatenate(*directory*, base64-encode(file)),
                  direction: #"output",
                  if-exists: #"replace");
  dood-root(dood) := *config*;
  dood-commit(dood);
  dood-close(dood);
  format(output-stream(response), "Saved database\n");
  #t;
end;

define method respond-to-get
    (page == #"restore", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "Restore Database")
    with-xml()
      div(id => "content") {
        form(action => "/restore", \method => "post") {
          \select(name => "filename") {
            do(let res = make(<list>);
               do-directory(method(directory :: <pathname>,
                                   name :: <string>,
                                   type :: <file-type>)
                                if (type == #"file")
                                  res := add!(res,
                                              with-xml()
                                                option(base64-decode(name),
                                                       value => name)
                                              end);
                                end if;
                            end, *directory*);
               res;)
          },
          input(type => "submit", name => "restore-button", value => "Restore")
        }
      }
    end;
  end;
end;

define method respond-to-post
    (page == #"restore", request :: <request>, response :: <response>)
  let file = get-query-value("filename");
  let dood = make(<dood>,
                  locator: concatenate(*directory*, file),
                  direction: #"input");
  *config* := dood-root(dood);
  dood-close(dood);
  format(output-stream(response), "Restored database\n");
  #t;
end;

define method respond-to-get
    (page == #"net", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template (out, "Networks")
    with-xml ()
      div(id => "content")
      {
        do(let res = make(<list>);
           for (net in *config*.config-nets,
                i from 0)
             res := concatenate(res, gen-xml(net));
             res := add!(res, with-xml()
                                form(action => "/net", \method => "post")
                                {
                                  div(class => "edit")
                                  {
                                    input(type => "hidden",
                                          name => "action",
                                          value => "gen-dhcpd"),
                                    input(type => "hidden",
                                          name => "network",
                                          value => integer-to-string(i)),
                                    input(type => "submit",
                                          name => "gen-dhcpd-button",
                                          value => "generate dhcpd.conf")
                                  }
                                }
                              end);
             res := add!(res, with-xml()
                                form(action => "net", \method => "post")
                                {
                                  div(class => "edit")
                                  {
                                    input(type => "hidden",
                                          name => "action",
                                          value => "remove-network"),
                                    input(type => "hidden",
                                          name => "network",
                                          value => integer-to-string(i)),
                                    input(type => "submit",
                                          name => "remove-network-button",
                                          value => "Remove this Network")
                                  }
                                }
                              end);
             res := add!(res, with-xml()
                                form(action => "/net", \method => "post")
                                {
                                  div(class => "edit")
                                  {
                                    text("CIDR"),
                                    input(type => "text", name => "cidr"),
                                    \select(name => "vlan")
                                    {
                                      do(do(
                                method(x)
                                    let num = integer-to-string(x.vlan-number);
                                    with-xml()
                                      option(name => num,
                                             value => concatenate(num,
                                                                  " ",
                                                                  x.vlan-name))
                                    end;
                                end, get-sorted-list(*config*.config-vlans)))
                                    },
                                    text("DHCP?"),
                                    input(type => "checkbox",
                                          value => "dhcp",
                                          checked => "checked",
                                          name => "dhcp"),
                                    text("DHCP start"),
                                    input(type => "text", name => "dhcp-start"),
                                    text("DHCP end"),
                                    input(type => "text", name => "dhcp-end"),
                                    text("DHCP router"),
                                    input(type => "text", name => "dhcp-router"),
                                    text("Default lease time"),
                                    input(type => "text",
                                          name => "default-lease-time"),
                                    text("Maximum lease time"),
                                    input(type => "text", name => "max-lease-time"),
                                    text("DHCP options"),
                                    input(type => "text", name => "options"),
                                    input(type => "hidden",
                                          name => "action",
                                          value => "add-subnet"),
                                    input(type => "hidden",
                                          name => "network",
                                          value => integer-to-string(i)),
                                    input(type => "submit",
                                          name => "add-subnet-button",
                                          value => concatenate
                                            ("Add subnet to",
                                             as(<string>, net.network-cidr)))
                                  }
                                }
                              end);
           end;
           res;),
        form(action => "/net", \method => "post")
        {
          div(class => "edit")
          {
            text("CIDR"),
            input(type => "text", name => "cidr"),
            text("DHCP?"),
            input(type => "checkbox",
                  value => "dhcp",
                  checked => "checked",
                  name => "dhcp"),
            text("Default lease time"),
            input(type => "text",
                  name => "default-lease-time"),
            text("Maximum lease time"),
            input(type => "text", name => "max-lease-time"),
            text("DHCP options"),
            input(type => "text", name => "options"),
            input(type => "hidden",
                  name => "action",
                  value => "add-network"),
            input(type => "submit",
                  name => "add-network-button",
                  value => "Add network")
          }
        }
      }
    end;
  end;
end;

define method respond-to-get
    (page == #"vlan", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "VLAN")
    with-xml()
      div(id => "content")
      {
        do(let res = make(<list>);
           do(method(x)
                  res := concatenate(res, gen-xml(x));
                  res := add!(res,
                              with-xml()
                                form(action => "/vlan", \method => "post")
                                  {
                                  div(class => "edit")
                                  {
                                    input(type => "hidden",
                                          name => "action",
                                          value => "remove-vlan"),
                                    input(type => "hidden",
                                          name => "vlan",
                                          value => integer-to-string(x.vlan-number)),
                                    input(type => "submit",
                                          name => "remove-vlan-button",
                                          value => "Remove VLAN")
                                  }
                                }
                              end);
              end, get-sorted-list(*config*.config-vlans));
           res),
        form(action => "/vlan", \method => "post")
        {
          div(class => "edit")
          {
            input(type => "hidden",
                  name => "action",
                  value => "add-vlan"),
            text("VLAN Number"),
            input(type => "text",
                  name => "vlan"),
            text("Name"),
            input(type => "text",
                  name => "name"),
            text("Description"),
            input(type => "text",
                  name => "description"),
            input(type => "submit",
                  name => "add-vlan-button",
                  value => "Add VLAN")
          }
        }
      }
    end;
  end;
end;

define method respond-to-get
    (page == #"host", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "Hosts")
    with-xml()
      div(id => "content")
      {
        table
        {
        tr { th("Name"), th("IP"), th("Net"), th("Mac"), th("Zone") },
        do(let res = make(<list>);
           for (net in *config*.config-nets)
             do(method(x)
                    res := add!(res, gen-xml(x));
                end, net.network-hosts);
           end;
           res)
        },
        form(action => "/host", \method => "post")
        {
          div(class => "edit")
          {
            text("Name"),
            input(type => "text", name => "name"),
            text("IP"),
            input(type => "text", name => "ip"),
            text("MAC"),
            input(type => "text", name => "mac"),
            \select(name => "zone")
            {
              do(let res = make(<list>);
                 do(method(x)
                        res := add!(res,
                                    with-xml()
                                      option(x.zone-name, value => x.zone-name)
                                    end);
                    end, choose(method(x)
                                    ~ zone-reverse?(x);
                                end, *config*.config-zones));
                 res)
            },
            input(type => "submit",
                  name => "add-host-button",
                  value => "Add Host")
          }
        }
      }
    end;
  end;
end;

define method respond-to-get
    (page == #"zone", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "Zones")
    with-xml()
      div(id => "content")
      {
        table
        {
          tr { th("Name") },
          do(let res = make(<list>);
             do(method(x)
                    res := add!(res, gen-xml(x));
                end, *config*.config-zones);
             res)
        },
        form(action => "/zone", \method => "post")
        {
          div(class => "edit")
          {
            text("Name"),
            input(type => "text", name => "name"),
            text("Hostmaster"),
            input(type => "text", name => "hostmaster"),
            text("Serial"),
            input(type => "text", name => "serial"),
            text("Retry"),
            input(type => "text", name => "retry"),
            text("Expire"),
            input(type => "text", name => "expire"),
            text("Minimum"),
            input(type => "text", name => "minimum"),
            text("Time to live"),
            input(type => "text", name => "time-to-live"),
            text("Nameserver"),
            input(type => "text", name => "nameserver"),
            text("Mail exchange"),
            input(type => "text", name => "mail-exchange"),
            text("txt"),
            input(type => "text", name => "txt"),
            input(type => "submit",
                  name => "add-zone-button",
                  value => "Add Zone")
          }
        }
      }
    end;
  end;
end;

define method respond-to-get
    (page == #"user", request :: <request>, response :: <response>)
  let out = output-stream(response);
  with-buddha-template(out, "User Interface")
    with-xml()
      div(id => "content")
      {
        do(show-host-info()),
        form(action => "/user", action => "post")
        {
          div(class => "edit")
          {
            text("Hostname"),
            input(type => "text", name => "hostname"),
            text("MAC"),
            input(type => "text", name => "mac"),
            input(type => "submit",
                  name => "add-host-button",
                  value => "Add Hostname")
          }
        }
      }
    end;
  end;
end;
      
define method respond-to-post
    (page == #"user", request :: <request>, response :: <response>)
  let ip = host-address(remote-host(request-socket(request)));
  let name = get-query-value("name");
  let mac = get-query-value("mac");
  let zone = *config*.config-zones[0];
  let network = find-network(*config*, ip);
  let host = make(<host>,
                  name: name,
                  ip: ip,
                  net: find-network(network, ip),
                  mac: parse-mac(mac),
                  zone: zone);
  add-host(network, host);
  respond-to-get(page, request, response);
end;

define method respond-to-post
    (page == #"net", request :: <request>, response :: <response>)
  let action = get-query-value("action");
  do-action(as(<symbol>, action), response)
end;

define method do-action (action == #"gen-dhcpd", response :: <response>)
 => (show-get? :: <boolean>)
  let network = get-query-value("network");
  network := *config*.config-nets[string-to-integer(network)];
  set-content-type(response, "text/plain");
  print-isc-dhcpd-file(network, output-stream(response));
  #f; //we don't want the default page!
end;

define method do-action (action == #"add-subnet", response :: <response>)
 => (show-get? :: <boolean>)
  let network = get-query-value("network");
  let cidr = get-query-value("cidr");
  let vlan = string-to-integer(get-query-value("vlan"));
  let dhcp? = if (get-query-value("dhcp") = "dhcp") #t else #f end;
  if (dhcp?)
    let default-lease-time
      = string-to-integer(get-query-value("default-lease-time"));
    let max-lease-time
      = string-to-integer(get-query-value("max-lease-time"));
    format-out("DHCP %= %=\n", default-lease-time, max-lease-time);
    let options = parse-options(get-query-value("options"));
    let dhcp-start = parse-ip(get-query-value("dhcp-start"));
    let dhcp-end = parse-ip(get-query-value("dhcp-end"));
    let dhcp-router = parse-ip(get-query-value("dhcp-router"));
    let subnet = make(<subnet>,
                      cidr: cidr,
                      vlan: vlan,
                      dhcp?: dhcp?,
                      default-lease-time: default-lease-time,
                      max-lease-time: max-lease-time,
                      options: options,
                      dhcp-start: dhcp-start,
                      dhcp-end: dhcp-end,
                      dhcp-router: dhcp-router);
    add-subnet(*config*.config-nets[string-to-integer(network)], subnet);
  else
    let subnet = make(<subnet>,
                      cidr: cidr,
                      vlan: vlan,
                      dhcp?: dhcp?);
    add-subnet(*config*.config-nets[string-to-integer(network)], subnet);
  end;
  #t;
end;

define method do-action (action == #"add-network", response :: <response>)
 => (show-get? :: <boolean>)
  let cidr = get-query-value("cidr");
  let dhcp? = if (get-query-value("dhcp") = "dhcp") #t else #f end;
  let default-lease-time
    = string-to-integer(get-query-value("default-lease-time"));
  let max-lease-time
    = string-to-integer(get-query-value("max-lease-time"));
  let options = parse-options(get-query-value("options"));
  let network = make(<network>,
                     cidr: cidr,
                     dhcp?: dhcp?,
                     max-lease-time: max-lease-time,
                     default-lease-time: default-lease-time,
                     options: options);
  add-net(*config*, network);
  #t;
end;

define method do-action (action == #"remove-network", response :: <response>)
 => (show-get? :: <boolean>)
  let network = get-query-value("network");
  remove-net(*config*, *config*.config-nets[string-to-integer(network)]);
  #t;
end;

define method parse-options (options) => (list :: <list>)
  format-out("OPTIONS %=\n", options);
  #();
end;

define method respond-to-post
    (page == #"vlan", request :: <request>, response :: <response>)
  let action = get-query-value("action");
  do-action(as(<symbol>, action), response);
end;

define method do-action (action == #"add-vlan", response :: <response>)
 => (show-get? :: <boolean>)
  let number = string-to-integer(get-query-value("vlan"));
  let name = get-query-value("name");
  let description = get-query-value("description");
  let vlan = make(<vlan>,
                  number: number,
                  name: name,
                  description: description);
  add-vlan(*config*, vlan);
  #t;
end;

define method do-action (action == #"remove-vlan", response :: <response>)
 => (show-get? :: <boolean>)
  let vlan = string-to-integer(get-query-value("vlan"));
  remove-vlan(*config*, vlan);
  #t;
end;

define method respond-to-post
    (page == #"zone", request :: <request>, response :: <response>)
  let name = get-query-value("name");
  let hostmaster = get-query-value("hostmaster");
  let serial = string-to-integer(get-query-value("serial"));
  let refresh = string-to-integer(get-query-value("refresh"));
  let retry = string-to-integer(get-query-value("retry"));
  let expire = string-to-integer(get-query-value("expire"));
  let minimum = string-to-integer(get-query-value("minimum"));
  let time-to-live = string-to-integer(get-query-value("time-to-live"));
  let nameserver = get-query-value("nameserver");
  let mail-exchange = get-query-value("mail-exchange");
  let txt = get-query-value("txt");
  let zone = make(<zone>,
                  name: name,
                  hostmaster: hostmaster,
                  serial: serial,
                  refresh: refresh,
                  retry: retry,
                  expire: expire,
                  minimum: minimum,
                  time-to-live: time-to-live,
                  nameserver: list(nameserver),
                  mail-exchange: list(mail-exchange),
                  txt: txt);
  *config*.config-zones :=
    sort!(add!(*config*.config-zones, zone));
  #t;
end;

define method respond-to-post
    (page == #"host", request :: <request>, response :: <response>)
  let name = get-query-value("name");
  let ip = make(<ip-address>, ip: get-query-value("ip"));
  let mac = get-query-value("mac");
  let zone = get-query-value("zone");
  let network = find-network(*config*, ip);
  let host = make(<host>,
                  name: name,
                  ip: ip,
                  net: find-network(network, ip),
                  mac: parse-mac(mac),
                  zone: find-zone(*config*, zone));
  add-host(network, host);
  #t;
end;

define function main () => ()
  block()
    start-server();
  exception (e :: <condition>)
    format-out("error: %=\n", e);
  end
end;

define function main2()
  let cisco = make(<cisco-ios-device>,
                   ip: "23.23.23.23",
                   login-password: "xxx",
                   enable-password: "xxx");

  let control = connect-to-cisco(cisco);
  control.run;

  send-command(control, "terminal length 0");
  let result = send-command(control, "show running");
  format-out("%s\n", result);
end;

begin
  let dood = make(<dood>,
                  locator: concatenate("/home/hannes/dylan/libraries/koala/www/buddha/", base64-encode("foo")),
                  direction: #"input");
  *config* := dood-root(dood);
  dood-close(dood);

  main();
end;

define method main3()
let foo =
with-xml-builder()
  html {
    head {
      title("foo")
    },
    body {
      div(id => "foobar",
          class => "narf") {
        a("here", href => "http://www.foo.com"),
        a(href => "http://www.ccc.de/"),
        text("foobar"),
        ul {
          li("foo"),
          br,
          li("bar"),
          br
        }
      }
    }
  }
end;
  format-out("%=\n", foo);
end;
