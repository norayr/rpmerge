unit build;

interface
uses itypes;
function finddep ( line : string ; confierror : string) : string;
function rebuild (folder : string ; put : location) : itypes.dinar;
implementation
uses ivars, iconsts, srcrpms, env, ShellUtils, nstringutils,
Unix, strutils, SysUtils;
function finddep ( line : string ; confierror : string) : string;

var i : integer;
begin
i := length (confierror);

repeat
inc(i);

until (line[i]=' ') or (line[i] = '(');
finddep := copy (line, length(confierror) + 1, i-length(confierror)-1)
end;

function rebuild (folder : string ; put : location) : itypes.dinar;
const errror : string = 'Error';
// la const errrror : string = './configure: No such file or directory';
const confierror : string = 'configure: error: You must have ';
var f : textfile;
fayl : srcrpm;
yerk : integer;
cline, line, t : string;
cflags : string;
pac : string;
sfile : string;
tmpst : string;
specfound : boolean;
begin
if verbose then begin
   writeln ('entered rebuild procedure');
   writeln ('ivars.BuildDir is ' + ivars.BuildDir);
   writeln ('first parameter "folder" is ' + folder);
end;
ivars.compiled := true;
pac := put.name;
tmpst := '';
line :='';
yerk := 1;
setlength (rebuild, yerk+1);
rebuild[1] := 'noerrors';
fayl := srcrpms.info(put.name);
fayl.url := put.url;
cflags := env.getcflags;

if (fayl.tesak = iconsts.targzext) or (fayl.tesak = iconsts.tarbzext) then
   begin
   if not ShellUtils.InPath('checkinstall') then 
     begin
     writeln ('checkinstall is not in path');
     writeln ('install checkinstall and try again');
     writeln ('it can be found at http://checkinstall.izto.org');
     halt;
     end;

   Unix.Shell ('rm -rf ' + ivars.BuildDir + '/BUILD/*');   
   Unix.Shell ('cp ' + ivars.DistDir +'/' + put.name + ' ' + ivars.BuildDir + '/BUILD/' + fayl.name + '-' + fayl.version + '.' + fayl.tesak);
   chdir (ivars.BuildDir + '/BUILD/');
   if fayl.tesak = iconsts.targzext then
      begin
      Unix.Shell ('tar zxvf ' + fayl.name + '-' + fayl.version + '.' + fayl.tesak);
      end;
   if fayl.tesak = iconsts.tarbzext then
      begin
      Unix.Shell ('tar ' + ivars.BunzipFlags  + ' ' + fayl.name + '-' + fayl.version + '.' + fayl.tesak);
      end;
   cline := 'ls -d */';
   Unix.popen (f, cline, 'R');
   
   readln (f, line);
   if ansilowercase(copy (line, 1, length(fayl.name))) =  ansilowercase(fayl.name) then
       begin
       chdir (line); 
       end
     else
       begin
       writeln ('no folder with unpacked sources found');
       writeln ('quitting');
       halt;  
       end;
   close (f);

   If fileexists('configure') then
       begin
      cline := 'export PKG_CONFIG_PATH="' + ivars.PkgConfigPath + '" ; export RPM_OPT_FLAGS="' + cflags + '"' + '; export CFLAGS="' + cflags + '"; export CXXFLAGS="' +  cflags + '";'  + ' ./configure';
      Popen (f, cline, 'R');
      repeat
      readln (f, line);
      writeln (line);
         if nstringutils.AnsiContainsText (line, confierror) then
            begin
            inc(yerk);
            rebuild[yerk-1] := finddep(line, confierror);
            exit;
            end;
      until eof(f);
      close (f);
      end;
                                        
cline := 'export PKG_CONFIG_PATH="' + ivars.PkgConfigPath + '" ; export RPM_OPT_FLAGS="' + cflags + '"; export CFLAGS="' + cflags + '"; export CXXFLAGS="' + cflags + '"'  + ' && ' + 'make' + ' 2>&1';
      Popen (f, cline, 'R');
      repeat
      readln (f, line);
      writeln (line);
         if AnsiContainsText (line, errror) then
            begin
            repeat
            readln (f, line);
            writeln (line);
            until eof(f);
            writeln ('error building package ' + put.name);
            writeln ('perhaps reasons are unsatisfied dependencies or outdated compiler');
            halt;
            end;
      until eof(f);
   Shell ('checkinstall -y -R');
   exit;
   end;


{
if fayl.tesak = tarbzext then
   begin
   Shell ('cp ' + ivars.DistDir + put.name + ' ' + ivars.BuildDir + 'SOURCES/' + fayl.name + '-' + fayl.version + '.' + fayl.tesak);
   sfile := create_specfile (fayl.url, fayl.name, fayl.version, fayl.tesak);
   cline := 'export CFLAGS="' + cflags + '"; ' + ivars.RpmBuildCommand + ' -ba ' + sfile;
      Popen (f, cline, 'R');
      repeat
      readln (f, line);
      writeln (line);
         if AnsiContainsText (line, errror) then
            begin
            repeat
            readln (f, line);
            writeln (line);
            until eof(f);
            writeln ('error building package ' + put.name);
            writeln ('perhaps reason is unsatisfied dependencies or outdated compiler');
            halt;
            end;


      until eof(f);
   exit;
   end;
}

if fayl.tesak = srcrpmext then
begin
//cline := rpmbuildcommand + rpmbuildparams + arch + ' ' + folder + pac + ' 2>&1';



// cline := 'export CFLAGS="' + cflags  + '"; epxort CXXFLAGS="' + cflags + '"; ' + ivars.RpmBuildCommand + ' --rebuild '  + ' ' + folder + pac + ' 2>&1';
 if verbose then writeln ('rpm -ivh ' + folder + '/' + pac);
 cline := 'rpm -ivh ' + folder + '/' + pac;
 shell (cline);
 sfile := fayl.name + '.spec';
 chdir (ivars.BuildDir + '/SPECS/');
 popen (f, 'ls ' + '*.spec 2>/dev/null', 'R');
 specfound := false;
 repeat
 readln (f, tmpst);
 
 if copy(tmpst, 1, length(fayl.name)) = fayl.name then 
    begin 
    shell ('mv -f ' + ivars.BuildDir + '/SPECS/'  + tmpst + ' ' + ivars.BuildDir + '/SPECS/' + sfile + ' 2>/dev/null' );
    specfound := true;
    end;
 if ansiuppercase(tmpst) = ansiuppercase(sfile) then 
    begin
    shell ('mv -f ' + ivars.BuildDir + '/SPECS/' + tmpst + ' ' + ivars.BuildDir + '/SPECS/' + sfile + ' 2>/dev/null');
    specfound := true;
    end;
 until eof(f);
 close (f);
 if not specfound then
   begin
   writeln ('no spec file found.');
   writeln ('it is a possibly bug in src.rpm where spec file name is not packagename.spec');
   writeln (iconsts.prname + ' can not work if buggy src.rpms');
   writeln ('you can try to find matching spec in ' + ivars.BuildDir + '/SPECS/' + 'and issue a command :');
   writeln ('rpmbuild -ba yourspecfile');
   writeln ('after you can manually install rpm packages');
   writeln ('exiting');
   halt;

   end;
 chdir (ivars.DistDir);
insertcflags (sfile, cflags); 
 cline := ivars.RpmBuildCommand + ' -ba ' + ivars.BuildDir  + '/SPECS/'  +  sfile + ' 2>&1'; 
// cline := rpmbuildcommand + ' --rebuild '  + ' ' + folder + pac + ' 2>&1';
 popen (f,  cline, 'R');


 repeat
 readln (f, line); 
 writeln (line);
 t := copy(line,1,length(rpmbuilderror));
 if ansicontainstext (t, rpmbuilderror) {t = rpmbuilderror} then
    begin
       compiled := false;
       readln (f, line);
       writeln (line); 
         repeat;   
                
         inc (yerk);
         setlength (rebuild, yerk);
         rebuild [yerk-1] := line;
         readln (f, line);
         writeln (line);
         until eof(f) or (copy(line, 1, length(rpmbuildmsg)) = rpmbuildmsg);
       
    end;

 if copy(line, 1, length(rpmbuilderrors)) = rpmbuilderrors then
    begin
    compiled := false;
    repeat
    readln (f, line);
    writeln (line);
    until eof(f);
    writeln ('can not build ' + pac + ' source');
    if al = false then
       begin
       writeln ('try to update compiler or glibc?');
       halt;
       end;
    end; 

 if copy(line, 1, length(rpmothererrors)) = rpmothererrors then
    begin
    compiled := false;
    repeat
    readln (f, line);
    writeln (line);
    until eof(f);
    if al = false then halt;
    end;

 until eof(f) ;


 close(f);

end;

end;

end.
