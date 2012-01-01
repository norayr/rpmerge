unit env;

interface
procedure insertcflags( spfile : string; flags : string);
function getcflags : string;

implementation

uses ivars, iconsts, nstringutils, Unix;

procedure insertcflags( spfile : string; flags : string);
const fla : string = 'CFLAGS="%{optflags}"';
var f : textfile;
 a, b : string;
 mm : array of string;
 i, j : integer;
begin
//j := 0;
i := 0;
a :='';
b :='';
a := ivars.BuildDir + '/SPECS/' + spfile;
assign (f, a);
reset (f);
   repeat
     inc (i);
     setlength (mm, i+1);
     readln (f, b);
     mm[i] := b;
   until ansicontainstext(b,'%build');
   inc (i);
   setlength (mm, i+1);
   mm[i] := 'CFLAGS="' + flags + '" CXXFLAGS="' + flags + '"';
   repeat
   readln (f, b);


   j := npos(fla, b, 1);
   if j <> 0 then
     begin
//     delete (b, j, length(b)-j+1); 
     delete (b, j, length(fla));
     end;

   inc(i);
   setlength (mm, i+1);
   mm[i] := b;
   until eof(f);
close (f);

assign (f, a);
rewrite (f);
for i := 1 to (length(mm)-1) do
   begin
   writeln (f, mm[i]);
   end;
close (f);
mm := nil;
end;

function getcflags : string;
const march : string = '-march';
var f : textfile;
    s : string;
   begin
   s := '';
   if ivars.ForceCompilerFlags <> 'yes' then
      begin
      popen (f, iconsts.prname + '.gcccpuopt.sh', 'R');
      readln (f, s);
      if copy(s, 1, length(march)) <> march then s := ivars.CompilerFlags;
      close (f);
      end
     else
      
      s :=  ivars.CompilerFlags;
      
   if ivars.OptimizationLevel = '' then ivars.OptimizationLevel := '-O2';
   getcflags := ivars.OptimizationLevel  + ' ' + s; 
   end;

end.
