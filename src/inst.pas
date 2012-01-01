unit inst;

interface
procedure install (s : string);
implementation
uses iconsts, itypes, UnixTools, ivars, srcrpms, Unix;
procedure install (s : string);
var l : string; 
 f : textfile;
 bash : string;
 s1 : itypes.srcrpm;
 i : byte;
 paths : UnixTools.dynar; 
begin
paths := UnixTools.GetProgramOutput('ls ' + ivars.BuildDir + '/RPMS/');
{setlength (paths, 7);
paths[1] := 'RPMS/i386/';
paths[2] := 'RPMS/i486/';
paths[3] := 'RPMS/i586/';
paths[4] := 'RPMS/i686/';
paths[5] := 'RPMS/noarch/';
}
l := '';
s1 := srcrpms.info(s);
s := s1.name;
for i := 1 to high(paths) do
begin
bash := 'ls ' + ivars.BuildDir + '/RPMS/' + paths[i];
Unix.Popen (f, bash, 'R');
delete (bash, 1, 3);
repeat
readln (f, l);
if  (copy(l,1,length(s)) = s) and (l[length(s)+1] = '-') and (copy(l, length(s)+1, length(iconsts.debuginfo)) <> iconsts.debuginfo)  then 
   begin
   Shell (iconsts.rpminstall + bash + '/' + l);  
   end;
until eof(f);
close(f);
end;
{
bash := 'ls ' + ivars.BuildDir + 'RPMS/' + 'noarch' + '/';
popen (f, bash, 'R');
delete (bash, 1, 3);
repeat
readln (f, l);
if  (copy(l,1,length(s)) = s) and (l[length(s)+1] = '-') and (copy(l, length(s)+1, length(debuginfo)) <> debuginfo)  then
   begin

   Shell (rpminstall + bash + l);

   end;

until eof(f);
close(f);
}


end;

end.
