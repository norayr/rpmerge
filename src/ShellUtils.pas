unit ShellUtils;


interface

uses iconsts, ivars, itypes,
     Unix;

function InPath ( st : string) : boolean ;
function Installed (s : itypes.srcrpm) : boolean;
function Download (lll : string; fle : string; where : string) : boolean;

implementation

uses srcrpms, nstringutils;


function InPath ( st : string) : boolean ;
var 
       f : textfile;
   s, s1 : string;
 
  begin
  inpath := false;
  s1 := st + ': /';
  s := '';
 
  Unix.popen (f, 'whereis ' + st, 'R');
  readln (f, s);
  if copy(s,1,length(s1)) = s1 then inpath := true;
  close(f);
 
end; //InPath

{
function wgetinstalled : boolean;
const wget_path : string = 'wget: /';
var f : textfile;
    s : string;
    
begin
wgetinstalled := false;
s := '';
popen (f, 'whereis wget', 'R');
readln (f, s);
if copy(s,1,length(wget_path)) = wget_path then wgetinstalled := true;
close(f);
end;
}


function installed (s : itypes.srcrpm) : boolean;
var tmmmp, s1, p, v : string;
    f : textfile;
    installedpackage : itypes.srcrpm;
//    i : integer;
begin

installed := false;
s1 := '';
//vr := '';
//vir := '';
p := s.name;
v := s.version;
tmmmp := rpmqa + '| grep ' + p;
popen (f, tmmmp, 'R');

repeat
readln (f, s1);
if  (copy(s1,1,length(p)) = p) and (s1[length(p)+1] = '-') and (copy(s1, length(p)+1, length(debuginfo)) <> debuginfo) then 
   begin
   installedpackage := info(s1);
   if installedpackage.version >= v then installed := true;
   end;

until eof(f);

close(f);

end;

function download (lll : string; fle : string; where : string) : boolean;
var
//    http : THTTPSend;
//    lllist : TStringList;
    url, pathtosave, tmppath, stro : string;
    f : textfile;
begin
   stro := '';
   download := false;
   url := lll + fle;
   pathtosave := where + '/' + fle;
   if verbose then begin
      writeln ('where is ' + where);
      writeln ('fle is ' + fle);
      writeln ('pathtosave is ' + pathtosave);
   end;
   tmppath := '/tmp/' + fle;
  

   if lll = ivars.DistDir then
     begin
     
     download := true;
     exit;
     end;

 
   if not InPath('wget') then
   begin
 
writeln ('install wget!');
halt;

   end;

//      Shell ('wget -O ' + tmppath + ' ' + url);
      Popen (f, 'wget -c -P ' + where + '/ ' + url + ' 2>&1', 'R');
      repeat
      readln (f, stro);
      writeln (stro);
      if ansicontainstext (stro, 'ERROR') then
           begin
           writeln ('failed to download ' + url);
           halt;
           end;
      until eof(f);
      //if ivars.verbose then writeln ('mv -f ' + tmppath + ' ' +  pathtosave);
      //Shell ('mv -f ' + tmppath + ' ' +  pathtosave + ' 2>/dev/null');
      download := true;
      if ivars.DownloadOnly then halt;
end;

end. //ShellUtils
