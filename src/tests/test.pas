uses unixtools, itypes;

var ss : itypes.dinar;
i : integer;
begin

ss := unixtools.getprogramoutput ('ls /usr/src/redhat');
for i := 0 to length(ss)-1 do
begin
writeln (ss[i])
end;
end.
