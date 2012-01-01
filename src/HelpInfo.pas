unit HelpInfo;

interface

uses SysUtils;

procedure writever;
procedure writehelp;


implementation
uses iconsts; 

procedure writever;
begin
writeln (iconsts.prname + ' ' + iconsts.prver + ' beta');
writeln ('by Norayr Chilingarian');
writeln ('licensed under GPLv3');
writeln ('released ' + iconsts.releasedate);
end;

procedure writehelp;
begin
   writeln ('usage :');
   writeln (iconsts.prname + ' update');
   writeln ('or');
   writeln (iconsts.prname + ' update-local');
   writeln ('or');
   writeln (iconsts.prname + ' -V');
   writeln ('or');
   writeln (iconsts.prname + ' [application] -n? (--no-questions)');
   writeln ('or');
   writeln (iconsts.prname + ' [application] -f (--force) -co(--compile-only)');
   writeln ('or');
   writeln (iconsts.prname + ' [application] -f (--force) -do(--download-only)');
   writeln ('or');   
   writeln (iconsts.prname + ' all');
   writeln;
   writeln ('example:');
   writeln (iconsts.prname + ' someapp');
   writeln (iconsts.prname + ' someapp -n?');
   writeln (iconsts.prname + ' someapp --noquestions');
   writeln;
end;



end. //HelpInfo
