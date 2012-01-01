{$mode objfpc}
{$h+}

unit nstringutils;


interface

uses sysutils;

function RightStr(const AText: String; const ACount: Integer): String;
function Extract_Word(N:Integer;S:String;WordDelims:TSysCharSet):String;
function Word_Count(Sentence: string; separator : char):integer;
function ExtractDelimited(N: Integer; const S: string; const Delims: TSysCharSet): string;
function NPos(const C: string; S: string; N: Integer): Integer;
function LeftStr(const AText: String; const ACount: Integer): String;
function AnsiContainsText(const AText, ASubText: string): Boolean;
function FindLatestCharPos (c : char; s : string) : integer;
function CopyTillEnd ( s : string ; i : integer) : string;

const
  DigitChars = ['0'..'9'];
  Brackets = ['(',')','[',']','{','}'];
  StdWordDelims = [#0..' ',',','.',';','/','\',':','''','"','`'] + Brackets;
  StdSwitchChars = ['-','/'];

implementation


function RightStr(const AText: String; const ACount: Integer): String;
begin
  Result := Copy(String(AText), Length(String(AText)) + 1 - ACount, ACount);
end;

function Extract_Word(N:Integer;S:String;WordDelims:TSysCharSet):String;
Var
I,J:Word;
Count:Integer;
SLen:Integer;
Begin
Count := 0;
I := 1;
Result := '';
SLen := Length(S);
While I <= SLen Do
Begin
While (I <= SLen) And (S[I] In WordDelims) Do Inc(I);
If I <= SLen Then Inc(Count);
J := I;
While (J <= SLen) And Not(S[J] In WordDelims) Do Inc(J);
If Count = N Then
Begin
Result := Copy(S,I,J-I);
Exit
End;
I := J;
End; {while}
End;

function Word_Count(Sentence: string; separator : char):integer;
var
    Words: integer;
 begin
    if Sentence <> '' then
    begin
      Words:=1;
      while Pos(separator, Sentence)<> 0 do
      begin
        Delete(Sentence,1,Pos(separator, Sentence));
        Inc(Words);
     end;
     Word_Count:=Words
   end
   else
    Word_Count:=0;
 end;


function ExtractDelimited(N: Integer; const S: string; const Delims: TSysCharSet): string;
var
  w,i,l,len: Integer;
begin
  w:=0;
  i:=1;
  l:=0;
  len:=Length(S);
  SetLength(Result, 0);
  while (i<=len) and (w<>N) do
    begin
    if s[i] in Delims then
      inc(w)
    else
      begin
      if (N-1)=w then
        begin
        inc(l);
        SetLength(Result,l);
        Result[L]:=S[i];
        end;
      end;
    inc(i);
    end;
end;

function NPos(const C: string; S: string; N: Integer): Integer;

var
  i,p,k: Integer;

begin
  Result:=0;
  if N<1 then
    Exit;
  k:=0;
  i:=1;
  Repeat
    p:=pos(C,S);
    Inc(k,p);
    if p>0 then
      delete(S,1,p);
    Inc(i);
  Until (i>n) or (p=0);
  If (P>0) then
    Result:=K;
end;

function LeftStr(const AText: String; const ACount: Integer): String;
begin
  Result := Copy(AText, 1, ACount);
end;

function AnsiContainsText(const AText, ASubText: string): Boolean;
begin
  Result := AnsiPos(AnsiUppercase(ASubText), AnsiUppercase(AText)) > 0;
end;

function FindLatestCharPos (c : char; s : string) : integer;
var i : integer;
begin
FindLatestCharPos := 0;
i := length(s);
repeat
if s[i] = c then FindLatestCharPos := i;
i := i - 1;
until (i = 1) or (FindLatestCharPos <> 0);

end;

function CopyTillEnd ( s : string ; i : integer) : string;

begin
CopyTillEnd := Copy (s, i, length(s) - i + 1);

end;


end.

