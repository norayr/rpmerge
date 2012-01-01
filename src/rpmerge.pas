{$mode objfpc}
uses 
     nstringutils, iconsts, itypes, ivars, ConfFile, Params, ShellUtils, SourceData,
     HelpInfo, srcrpms, UnixTools, basic, env, inst, build,
     Classes, BaseUnix, Unix, SysUtils;


begin
   if not ShellUtils.InPath('wget') then
   begin
      writeln ('cannot find wget downloader');
      writeln ('please install wget and run me again');
      halt;
   end;
   ivars.CompileOnly := false;
   ivars.DownloadOnly := false;
   al := false;   
   force := false;
   questions := true;
   ivars.ForceCompilerFlags := 'no';
   if ConfFile.CheckConfFile = false then ConfFile.CreateConfFile;
   ConfFile.LoadConfFile;
   SourceData.DistDirCheck;
   ivars.urls := ConfFile.CreateUrlArray();
   Params.Checkparams;
   SourceData.CheckSourcesDataFile;
   ivars.urls := nil;
   patet := ParamStr(1);
   work(patet, '');
end.

