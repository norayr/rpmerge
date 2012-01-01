{$mode objfpc}
/////{$h+}

unit ConfFile;


interface

uses iconsts, ivars, itypes, nstringutils,
     SysUtils;

function CheckConfFile : boolean;
procedure CreateConfFile;
procedure LoadConfFile;
function CreateUrlArray : itypes.dinar;



implementation
const dist_dir : string = '/var/' + iconsts.prname;
const build_dir : string = 'BUILD_DIR';
const rpmbuild_command : string = 'RPMBUILD_COMMAND';
const optimization_level : string = 'OPTIMIZATION_LEVEL';
const compiler_flags : string = 'COMPILER_FLAGS';
const force_compiler_flags : string = 'FORCE_COMPILER_FLAGS';
const pkgconfig_path : string = 'PKG_CONFIG_PATH';
const bunzip_flags : string = 'BUNZIP_FLAGS';

function CheckConfFile : boolean;
begin
   if FileExists(iconsts.conffile) then CheckConfFile := true else CheckConfFile := false;
end;

procedure CreateConfFile;
// la const pkgconfigpath : string = 'PKG_CONFIG_PATH';
var f : textfile;
begin
   writeln ('configuration file ' + iconsts.conffile + ' not found.');
   writeln ('creating configuration file...');
   writeln ('you can add there srpms containing urls');
   assign (f, iconsts.conffile);
   rewrite (f);
   writeln (f, '# this is configuration file for ' + iconsts.prname);
   writeln (f, '# put here http urls with srpm files');

   writeln (f, '#ftp://ftp.redhat.com/pub/redhat/linux/enterprise/4/en/os/x86_64/SRPMS/');
   writeln (f, 'ftp://ftp.redhat.com/pub/redhat/linux/enterprise/5Server/en/os/SRPMS/');
   writeln (f, 'http://download.fedora.redhat.com/pub/epel/5/SRPMS/');
   writeln (f, 'http://download1.rpmfusion.org/free/el/updates/testing/5/SRPMS/');
   writeln (f, 'http://repo.redhat-club.org/redhat/5/SRPMS/');
   writeln (f, '#ftp://rpmfind.net/linux/dag/fedora/6/en/SRPMS.rpmforge/');
   writeln (f, 'ftp://rpmfind.net/linux/dag/redhat/el5/en/SRPMS.rpmforge');
   writeln (f, '#http://download.fedora.redhat.com/pub/fedora/linux/releases/9/Everything/source/SRPMS/'); 
   writeln (f, '#http://download.fedora.redhat.com/pub/fedora/linux/releases/11/Fedora/source/SRPMS/'); 
   writeln (f, '#ftp://fr2.rpmfind.net/linux/Mandriva/official/2009.1/SRPMS/main/release/'); 
   writeln (f, ''); 
   writeln (f, ''); 
{   writeln (f, iconsts.default_srpms_url);
   writeln (f, iconsts.default_srpms_url2);
   writeln (f, iconsts.default_srpms_url3);
   writeln (f, iconsts.default_srpms_url4);}
   writeln (f, dist_dir + '="/var/'+ iconsts.prname + '"');
   writeln (f, '# build directory');
   writeln (f, build_dir + '="/usr/src/redhat"');
   writeln (f, '#rpm build command is "rpmbuild" in redhat/fedora and "rpm" in suse');
   writeln (f, rpmbuild_command + '="rpmbuild"');
   writeln (f, '#optimization level');
   writeln (f, '#' + optimization_level + '="-O3"');
   writeln (f, '#if cpu detection files then use this default options');
   writeln (f, '#' + compiler_flags + '="-march=i386"');
   writeln (f, '#' + compiler_flags + '="-march=athlon64"');
   writeln (f, '#force above compiler flags, do not detect cpu');
   writeln (f, '# + ' + force_compiler_flags + '="yes"');
   writeln (f, '#you sometemis need to set PKG_CONFIG_PATH environment variable when compiling tarballs');
   writeln (f, pkgconfig_path + '="/usr/lib/pkgconfig"');
   writeln (f, '#on the older systems to bunzip2 tar.bz2 archive you need to issue tar Ixvf and on the modern systems tar jxvf');
   writeln (f, bunzip_flags + '="jxvf"');
   close (f);
end; //CreateConfFile

procedure LoadConfFile;
var f : textfile;
    s : string;
begin
if ivars.verbose then writeln ('loading configuration');
s := '';
assign (f, iconsts.conffile);
reset (f);
while not EOF(f) do
begin
readln (f, s);
if copy (s,1,length(dist_dir)) = dist_dir then 
begin
   ivars.DistDir := nstringutils.ExtractDelimited (2, s, ['"']); 
   ivars.SourcesDataFile := ivars.DistDir + '/' + iconsts.sources_data_file;
   if ivars.verbose then begin
   writeln ('DistDir is ' + ivars.DistDir);
   writeln ('Sources file is ' + ivars.SourcesDataFile);
   end;
end; //if   
if copy (s,1,length(build_dir)) = build_dir then ivars.BuildDir := nstringutils.ExtractDelimited (2, s, ['"']); 
if copy (s,1,length(rpmbuild_command)) = rpmbuild_command then ivars.RpmBuildCommand := nstringutils.extractdelimited (2, s, ['"']);
if copy (s, 1, length(optimization_level)) = optimization_level then ivars.OptimizationLevel := extractdelimited (2, s, ['"']);
if copy (s, 1, length(compiler_flags)) = compiler_flags then ivars.CompilerFlags := nstringutils.ExtractDelimited (2, s, ['"']);
if copy (s, 1, length(force_compiler_flags)) = force_compiler_flags then  ivars.ForceCompilerFlags := nstringutils.ExtractDelimited (2, s, ['"']);
if copy (s, 1, length(pkgconfig_path)) = pkgconfig_path then ivars.PkgConfigPath := nstringutils.ExtractDelimited (2, s, ['"']);
if copy (s, 1, length(bunzip_flags)) = bunzip_flags then BunzipFlags := nstringutils.ExtractDelimited (2, s, ['"']);
end;

close (f);
end; //LoadConfFile

function CreateUrlArray : dinar;
var f : textfile;
    togh : string;
    i, count : byte;
begin
{finding urls count}
   assign (f, iconsts.conffile);
   reset (f);
   count := 0;
   togh := '';
   repeat
         readln (f, togh);
         if    (Copy (togh, 1, length(iconsts.http_prefix)) = iconsts.http_prefix) 
	    or 
	       (Copy(togh, 1, length(iconsts.ftp_prefix))= iconsts.ftp_prefix) then
         begin
           Inc(count);
         end;
   until EOF(f) or (count > 250);
   close (f);
   {creating array}
   setlength (CreateUrlArray, ( count + 1 ) );
   assign (f, iconsts.conffile);
   reset (f);
   i := 0;
   repeat
      readln (f, togh);
      if (Copy (togh, 1, length(iconsts.http_prefix)) = iconsts.http_prefix) or (Copy(togh, 1, length(iconsts.ftp_prefix))= iconsts.ftp_prefix) then
      begin
         inc(i);
	 //writeln (togh[length(togh)]);
	 if togh[length(togh)] <> '/' then togh := togh + '/';
         CreateUrlArray[i] := togh;      
	 if ivars.verbose then begin writeln(togh); {writeln (togh[length(togh)-1]);} end;
	 //inc(i)
      end;
   until i = count;
   close (f);
end; //CreateUrlArray

end. //ConfFile
