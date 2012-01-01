unit basic;

interface
procedure all;
function work(packagename : string ; requiredversion : string) : boolean;
function work_for_all(packagename : string ; requiredversion : string) : boolean;

implementation
uses iconsts, ivars, itypes, nstringutils, srcrpms, ShellUtils, inst, build, Unix;

function work(packagename : string ; requiredversion : string) : boolean;
var path : itypes.location;
sourcerpm : itypes.srcrpm;

list : array of string;
i, j : integer;
begin
work := false;
i := 0;
j := 0;

   if nstringutils.RightStr(PackageName, length(iconsts.devel)) = iconsts.devel then
   begin
         writeln ('src.rpm never supposed to be a devel (example mjpegtools-devel) package');
         delete (PackageName, (length(PackageName)-length(iconsts.devel)) + 1, length(iconsts.devel));
         writeln ('using ' + PackageName);
   end;

path := srcrpms.FindMatchingSrpm(packagename, requiredversion);

if not (path.name = 'installed') then
begin
   writeln ('downloading ' + path.url + path.name);
   if ShellUtils.download (path.url, path.name, ivars.DistDir) = true  then
      begin
       writeln ('file ' + path.name + ' saved');
          repeat
          
          list := build.rebuild(ivars.DistDir, path);
          if not (list[1] = 'noerrors') then
             begin
                j := length(list)-1;
                for i := 1 to j do
                   begin
                   sourcerpm := parsereq (list[i]);
                   work (sourcerpm.name, sourcerpm.version);
                   end;
             end
           else
             begin
             writeln ('compilation succesfull');
             if ivars.CompileOnly then begin
	     writeln ('skipping installation');
	     end
	    else
	     begin
	     writeln ('installing... ');
             inst.install (path.name);
	     end;
             work := true;
             end;
           until list[1] = 'noerrors';


    end
    else
    begin
    writeln ('download failed');
    halt;    
    end;
end;


end;

procedure markdone(pa : string);
var i : integer;
begin
i := 0;
for i := 1 to (length(m)-1) do
   begin
   if copy(m[i], 1, length(pa)) = pa then m[i] := 'alreadydone';

   end;
   writeln (' marking ' + pa + ' as traversed');
   writeln;
end;


function work_for_all(packagename : string ; requiredversion : string) : boolean;
var path : location;
sourcerpm : srcrpm;
list : array of string;
i, j : integer;
begin
work_for_all := false;
i := 0;
j := 0;

path := findmatchingsrpm_all(packagename, requiredversion);

if not (path.name = 'not_found') then
begin
   writeln ('downloading ' + path.url + path.name);

   if download (path.url, path.name, ivars.DistDir) = true  then
      begin
       writeln ('file ' + path.name + ' saved');
          repeat

          list := rebuild(ivars.DistDir, path);
          if not (list[1] = 'noerrors') then
             begin
                j := length(list)-1;
                for i := 1 to j do
                   begin
                   sourcerpm := parsereq (list[i]);
                   work_for_all(sourcerpm.name, sourcerpm.version);
                   end;
             end
           else
             begin
             if compiled = true then
                begin
                writeln ('compilation succesfull');
                writeln ('installing... ');
                install (path.name);
                end;
                markdone(packagename);
                work_for_all := true;
             end;
           until list[1] = 'noerrors';


    end
    else
    begin
    writeln ('download failed');
    halt;
    end;
end;

end;


procedure all;
var f : textfile;
y, u : string;
//i, j : integer;

sssourceee : srcrpm;
begin
y := '';
u := '';
ii := 0;
jj := 0;
y := 'rpm -qa';

questions := false;
Unix.popen (f, y, 'R');
   repeat
   readln (f, u);
   inc (ii);
   setlength (m, ii+1);
   m[ii] := u;
   until eof(f);
close (f);

for jj := 1 to ii do
   begin
   if m[jj] <> 'alreadydone' then
      begin
      sssourceee := info (m[jj] + '.' + srcrpmext);  
      if (copy(sssourceee.name, 1, length('glibc')) <> 'glibc') and (copy(sssourceee.name, 1, length('kernel')) <> 'kernel') then work_for_all (sssourceee.name, sssourceee.version );
      end;      

   end;

m := nil;
end;

end.
