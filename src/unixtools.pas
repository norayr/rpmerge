Unit UnixTools;


interface

uses unix, sysutils, Dos;
type dynar = array of string;
function inpath ( st : string) : boolean ;
function getprogramoutput (s : string) : dynar;
FUNCTION concatarrays ( a,b : dynar) : dynar;
FUNCTION addtoarray ( VAR a : dynar; s : string) : BOOLEAN;
FUNCTION listdir(s , pattern : STRING) : unixtools.dynar;

implementation

function inpath ( st : string) : boolean ;

var f : textfile;
    s, s1 : string;

begin
inpath := false;
s1 := st + ': /';
s := '';

popen (f, 'whereis ' + st, 'R');
readln (f, s);
if copy(s,1,length(s1)) = s1 then inpath := true;
close(f);

end;

function getprogramoutput (s : string) : dynar;
var f : textfile;
a : dynar;
str : string;
i : integer;
begin
i :=0;

popen (f, s, 'R');


//while not eof(f) do begin
repeat
	inc (i);
	setlength (a, i); 
	readln (f, str);            // writeln ('got from pipe ',str);
	a[i-1] := str;
//end;
until eof (f);

getprogramoutput := a;
end {getcommandoutput};


FUNCTION concatarrays ( a,b : dynar) : dynar;
VAR n : dynar;
i,j : INTEGER;
BEGIN
SETLENGTH (n, ( HIGH(a) + HIGH(b) + 1 ) );

i := 0;
REPEAT
n[i] := a[i];
INC(i);
UNTIL i = LENGTH(a);
j := 0;
REPEAT
n[i] := b[j];
INC(i);
INC(j);
UNTIL j = LENGTH (b);
concatarrays := n;
END;

FUNCTION addtoarray ( VAR a : dynar; s : string) : BOOLEAN;
VAR i : INTEGER;
BEGIN
addtoarray := FALSE;
i := 0;
REPEAT
   IF a[i]=s THEN  exit ;
   INC(i);
UNTIL i= LENGTH(a);

SETLENGTH(a, ( LENGTH(a) + 1 ) );
a[HIGH(a)] := s;
addtoarray := TRUE;
END {addtoarray};

 FUNCTION listdir(s , pattern : STRING) : unixtools.dynar;
 var a : unixtools.dynar;
 Dir : SearchRec;
 BEGIN
 Chdir (s);
 SetLength (a,1);
 FindFirst(pattern,directory,Dir);
//  WriteLn('FileName'+Space(32),'FileSize':9);
  while (DosError=0) do
   begin
   a[HIGH(a)] := Dir.Name;
//   WriteLn (a[HIGH(a)]);
   SetLength(a,HIGH(a)+2);
   
    // Writeln(Dir.Name+Space(40-Length(Dir.Name)),Dir.Size:9);
    
     FindNext(Dir);
   end;
  FindClose(Dir);
 listdir := a;
 END {listdir};



begin


end.



