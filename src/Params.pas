unit params;

interface
procedure CheckParams;

implementation
uses SourceData, HelpInfo, ivars, basic;
procedure CheckParams;
const forcee : string = '-f';
const forrce : string = '--force';
const ql : string = '-n?';
const ql1 : string = '--no-questions';
const compileonly = '--compile-only';
const compileonly2 = '-co';
const downloadonly = '--download-only';
const downloadonly2 = '-do';
begin
   if (ParamStr(1)='') or (ParamStr(1) = '--help') or (ParamCount > 3) or (ParamCount = 0) then
   begin
      writehelp;
      halt;
   end;
   
   if ParamStr(1) = '-V' then
     begin
     writever;
     halt;
   end;

   if ParamStr(1) = 'update' then
   begin
      SourceData.update;
      halt;
   end;
   if ParamStr(1) = 'update-local' then
   begin
      SourceData.updatelocal;
   halt;
   end;
   
   if ParamStr(1) = 'all' then
   begin
      ivars.al := true;
      basic.all;
      halt;
   end;

if ParamCount = 2 then
    begin
    if (ParamStr(2) = ql) then questions := false;
    if (ParamStr(2) = ql1) then questions := false;
    if (ParamStr(2) = forcee) then force := true;
    if (ParamStr(2) = forrce) then force := true;
    end;

if ParamCount = 3 then
   begin
   if (ParamStr(2) = ql) then questions := false;
   if (ParamStr(2) = ql1) then questions := false;
   if (ParamStr(3) = ql) then questions := false;
   if (ParamStr(3) = ql1) then questions := false;
   if (ParamStr(2) = forcee) then force := true;
   if (ParamStr(2) = forrce) then force := true;
   if (ParamStr(3) = forcee) then force := true;
   if (ParamStr(3) = forrce) then force := true;
   if (ParamStr(2) = compileonly) then ivars.CompileOnly := true;
   if (ParamStr(2) = compileonly2) then ivars.CompileOnly := true;
   if (ParamStr(3) = compileonly) then ivars.CompileOnly := true;
   if (ParamStr(3) = compileonly2) then ivars.CompileOnly := true;
   if (ParamStr(2) = downloadonly) then ivars.DownloadOnly := true;
   if (ParamStr(2) = downloadonly2) then ivars.DownloadOnly := true;
   if (ParamStr(3) = downloadonly) then ivars.DownloadOnly := true;
   if (ParamStr(3) = downloadonly2) then ivars.DownloadOnly := true;
   end;
{
if ParamCount = 3 then
    begin
    if ParamStr(3) = ql then questions := false;
    if ParamStr(3) = ql1 then questions := false;
    if (ParamStr(2) = ql) then questions := false;
    if (ParamStr(2) = ql1) then questions := false;    
    if ParamStr(2) = 'i386' then ar := ParamStr(2);
    if ParamStr(2) = 'i486' then ar := ParamStr(2);
    if ParamStr(2) = 'i586' then ar := ParamStr(2);
    if ParamStr(2) = 'i686' then ar := ParamStr(2);
    if ParamStr(2) = 'athlon' then ar := ParamStr(2);
    if ParamStr(2) = 'ppc' then ar := ParamStr(2);
    if ParamStr(3) = 'i386' then ar := ParamStr(2);
    if ParamStr(2) = 'i486' then ar := ParamStr(2);
    if ParamStr(3) = 'i586' then ar := ParamStr(2);
    if ParamStr(3) = 'i686' then ar := ParamStr(2);
    if ParamStr(3) = 'athlon' then ar := ParamStr(2);
    if ParamStr(3) = 'ppc' then ar := ParamStr(2);
    end;
}
end; //CheckParams




end.

