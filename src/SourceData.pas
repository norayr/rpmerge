{$mode objfpc}

unit SourceData;

interface

procedure CheckSourcesDataFile;
procedure updatelocal;
procedure update;
procedure DistDirCheck;


implementation

uses iconsts, ivars, ShellUtils, parse,
     Unix, SysUtils;

procedure CheckSourcesDataFile;
var f : textfile ;
    b : boolean;
    t : string;
begin
   b := false;
   t := '';
   try
      assign (f, ivars.SourcesDataFile);
      reset (f);
         repeat
         readln (f, t);
         if t = iconsts.sources_data_file_footer then b := true;
         until EOF(f);
      close (f);
   except
      if b = false then
         begin
         writeln ('Your srpms data file ' + ivars.SourcesDataFile + ' is corrupted');
         writeln ('or does not created yet');
         writeln ('Check internet connection and make');
         writeln (iconsts.prname + ' update');
         writeln ('to (re)create file');
         halt;
         end;
   end;
end; //CheckSourcesDataFile

procedure updatelocal;
const tmp_file = '/tmp/' + iconsts.prname +'.temp';
var f : textfile;
stri : string;
sources : array of string;
i,j : integer;
begin
writeln ('updating only local sources list ;)');
i := 0;
j := 0;
stri := '';
if fileexists(ivars.SourcesDataFile) then
begin
   assign (f, ivars.SourcesDataFile);
   reset(f);
      repeat
      inc(i);
      setlength (sources, i+1);
      readln (f, stri);
      sources[i] := stri;
      until stri = ivars.DistDir;
   close (f);
   assign (f, ivars.SourcesDataFile);
   rewrite (f);
   for j := 1 to i do
      begin
      writeln (f, sources[j]);
      end;
   close (f);
end;
WriteLn ('Writing sources list from ' + ivars.DistDir + ' to ' + ivars.SourcesDataFile);
if not fileexists(ivars.SourcesDataFile) then
   begin
   assign (f, ivars.SourcesDataFile);
   rewrite (f);
   close(f);
   end;
//Shell ('echo ' + iconsts.workdir + ' >> ' + ivars.SourcesDataFile );
Shell ('ls *.' + iconsts.srcrpmext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
Shell ('ls *.' + iconsts.targzext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
Shell ('ls *.' + iconsts.tarbzext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
   
Shell ('echo "' + iconsts.sources_data_file_footer + '" >> ' + ivars.SourcesDataFile);
sources := nil;
end;

procedure update;
const tmp_file = '/tmp/' + iconsts.prname + '.temp';
var 
//http : THTTPSend;
//    l: tstringlist;
    i : byte;
    t : string;
    f : textfile;
begin

if length(ivars.urls) = 1 then
   begin
   writeln ('there are no urls in your config file');
   writeln ('rewriting ' + ivars.SourcesDataFile);
      assign (f, ivars.SourcesDataFile);
      rewrite (f);
      writeln (f, ivars.DistDir);
      close (f);
   updatelocal;
   exit;
   end;

writeln ('updating srpms database');

   assign (f, ivars.SourcesDataFile);
   rewrite(f);
   close(f);
   i := 0;
      repeat
      assign (f, tmp_file);
      rewrite (f);
      close (f);

      inc(i);
      t := ivars.urls[i];
    
	 Shell ('wget -O ' + tmp_file + ' ' + t);
           WriteLn ('Writing source rpms list from ' + ivars.urls[i] + ' to ' + ivars.SourcesDataFile);
           Unix.Shell ('echo "' + ivars.urls[i] + '" >> ' + ivars.SourcesDataFile);
           Parse.extractlinks(tmp_file, ivars.SourcesDataFile);
	 

      until i = (length(ivars.urls)-1);
WriteLn ('Writing source rpms list from ' + ivars.DistDir + ' to ' + ivars.SourcesDataFile);

Shell ('echo ' + ivars.DistDir + ' >> ' + ivars.SourcesDataFile );
Shell ('ls *.' + iconsts.srcrpmext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
Shell ('ls *.' + iconsts.targzext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
Shell ('ls *.' + iconsts.tarbzext + ' >> ' + ivars.SourcesDataFile + ' 2>/dev/null');
   
Shell ('echo "' + iconsts.sources_data_file_footer + '" >> ' + ivars.SourcesDataFile);

end;


procedure DistDirCheck;
begin
   If not FileExists (ivars.DistDir) then
   begin
   Writeln ('Creating work folder ' + ivars.DistDir);
   mkdir (ivars.DistDir);
   end;
chdir (ivars.DistDir);
end; //DistDirCheck



end. //SourceData
