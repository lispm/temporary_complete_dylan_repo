module: dylan-user

define library xmpp-test
  use common-dylan;
  use io;
  use network;
  use xml-parser;
  use xmpp;
  use meta;
end library;

define module xmpp-test
  use common-dylan;
  use format-out;
  use sockets;
  use streams;
  use standard-io;
  use xml-parser;
  use simple-xml;
  use xmpp;
  use meta;
  use %productions;
  use printing;
  use threads;
end module;
