module: buddha
author: Hannes Mehnert <hannes@mehnert.org>

define web-class <host> (<object>)
  data host-name :: <string>;
  data ipv4-address :: <ip-address>;
  data mac-address :: <mac-address>;
  has-a subnet;
  has-a zone;
end;

define method make (host == <host>,
                    #next next-method,
                    #rest rest,
                    #key ip,
                    #all-keys) => (res :: <host>)
  let args = rest;
  if (instance?(ip, <string>))
    args := exclude(args, #"ip");
    ip := make(<ip-address>, data: ip);
  end;
  apply(next-method, host, ip: ip, args);
end method;

define method print-object (host :: <host>, stream :: <stream>)
 => ()
  format(stream, "Host %s Zone  Mac %s\n",
         host.host-name,
//         host.zone.zone-name,
         as(<string>, host.mac-address));
  format(stream, "IP %s Net %s\n",
         as(<string>, host.ipv4-address),
         as(<string>, host.subnet.cidr));
end;

define method \< (a :: <host>, b :: <host>) => (res :: <boolean>)
  a.ipv4-address < b.ipv4-address
end;

define method as (class == <string>, host :: <host>)
 => (res :: <string>)
  concatenate(host.host-name, " ", as(<string>, host.ipv4-address));
end;

define method gen-xml (host :: <host>)
  with-xml()
    tr
    {
      td(host.host-name),
      td(as(<string>, host.ipv4-address)),
      td(as(<string>, host.subnet.cidr)),
      td(as(<string>, host.mac-address)),
//      td(host.zone.zone-name)
    }
  end;
end;

define method print-isc-dhcpd-file (host :: <host>, stream :: <stream>)
 => ()
  format(stream, "host %s {\n", host.host-name);
  format(stream, "\thardware ethernet %s;\n", as(<string>, host.mac-address));
  format(stream, "\tfixed-address %s;\n", as(<string>, host.ipv4-address));
  format(stream, "}\n\n");
end;

