unit srcrpms;

interface

uses iconsts, itypes, nstringutils, ShellUtils,
 SysUtils;

function info( srpmname : string) : itypes.srcrpm;
function FindMatchingSrpm ( p : string; v : string) : itypes.location;
function FindMatchingSrpm_all ( p : string; v : string) : itypes.location;
function StringContainsSrcrpm (inp : string) : boolean;
function ExtractSrcrpmName ( inpu : string) : string;
function parsereq (source : string) : srcrpm;
implementation
uses ivars,
     Unix;

function parsereq (source : string) : srcrpm;
begin

parsereq.name := extract_word( 1, source, [' ', ',',#9]);
{
if right_str(parsereq.name, length(devel)) = devel then
   begin
   delete (parsereq.name, (length(parsereq.name)-length(devel)) + 1, length(devel));

   end;
}       
parsereq.version := extract_word ( 3, source, [' ']);
if parsereq.version = 'needed' then parsereq.version := '0';

{
writeln ('');
writeln (parsereq.name);
writeln (parsereq.version);
}

end;


function info( srpmname : string) : itypes.srcrpm;
var i, lina, n : integer;
    
begin
   i :=0;
   n :=0;
   lina := length(srpmname);
   info.fullname := srpmname;
      for i:=1 to (lina-1) do
         begin
         if (srpmname[i] = '-') and (srpmname[i+1] in ['0'..'9']) then
             begin
             info.name := copy(srpmname, 1, (i-1));
             if nstringutils.RightStr (srpmname, length(iconsts.srcrpmext)) = iconsts.srcrpmext then
                begin
                n := npos (iconsts.srcrpmext, srpmname, 1);
                n := n - 1;
                delete (srpmname, n, (length(iconsts.srcrpmext)+1));
                info.tesak := iconsts.srcrpmext;
                end;
             if nstringutils.RightStr (srpmname, length(iconsts.targzext)) = iconsts.targzext then
                begin
                n := npos (iconsts.targzext, srpmname, 1);
                n := n - 1;
                delete (srpmname, n, (length(iconsts.targzext)+1));
                info.tesak := iconsts.targzext;
                end;
             if nstringutils.RightStr (srpmname, length(iconsts.tarbzext)) = iconsts.tarbzext then
                begin
                n := npos (iconsts.tarbzext, srpmname, 1);
                n := n - 1;
                delete (srpmname, n, (length(iconsts.tarbzext)+1));
                info.tesak := iconsts.tarbzext;
                end;

             repeat
             n := n - 1;
             until (srpmname[n] in ['0'..'9']);
             delete (srpmname, n+1, length(srpmname)-n);
             info.version := copy(srpmname, i+1, (length(srpmname)-1));
             exit; 	     
             end;  
         end;
end;


function FindMatchingSrpm ( p : string; v : string) : itypes.location;

var f : textfile;
    link, s1, rrr : string;
    t, l, i : integer;
    s2, s3 : string;
    j : integer;

{
    versions : array of  string;
    links : array of string;
    names : array of string;
}
    CompVer : array of string;
    SourceArray : array of itypes.srcrpm;
    r : char;
    rr : integer;
    srpm : itypes.srcrpm;
    temptype : itypes.srcrpm;
    temptype2 : itypes.srcrpm;
    tmploc : itypes.location;    
    correct : boolean;

begin
   temptype2.name := p;
   temptype2.version := v;
   s2 := '';
   s3 := '';
   j := 0;



   FindMatchingSrpm.name := 'installed';

   if nstringutils.RightStr(p, length(iconsts.devel)) = iconsts.devel then
   begin
           delete (p, (length(p)-length(iconsts.devel)) + 1, length(iconsts.devel));
   end;

   if nstringutils.LeftStr(p, length(iconsts.usrbinpath)) = iconsts.usrbinpath then
   begin
        delete (p, 1, length(iconsts.usrbinpath));
   end;

   s1 := '';
   l := 0;
   i := 0;
   link := '';
   rrr := '0000';
      
   assign (f, ivars.SourcesDataFile);
   reset (f);

   repeat
   readln (f, s1);
   if     (copy(s1,1, length(p)) = p) 
      and (s1[length(p)+1] = '-')  
      and (s1[length(p)+2] in ['0'..'9']) then 
   begin
                                                  inc(l);   
   end;//if

   until EOF(f);

   close (f);
   // now we now how many packages with the p name is in the SourcesDataFile

{
  setlength (versions, l+1);
  setlength (links, l+1);
  setlength (names, l+1);
}
   SetLength (SourceArray, l + 1);
   assign (f, SourcesDataFile);
   reset (f);

   //creating an array with versions to let user select version   
      repeat
         ReadLn (f, s1);
         if    (Copy (s1, 1, Length(iconsts.http_prefix)) = iconsts.http_prefix) 
            or (Copy(s1, 1, length(ivars.DistDir)) = ivars.DistDir)
            or (Copy (s1, 1, length(iconsts.ftp_prefix)) = iconsts.ftp_prefix) then 
         begin
           link := s1;
         end
        else
         begin
            srpm := info(s1);
            srpm.url := link;
            if srpm.name = p then
            begin
               inc(i);
               {
               versions[i] := srpm.version;
               links[i] := link;
               names[i] := s1;
                }
               SourceArray[i] := srpm;
            end;
         end;
      until EOF(f) or (i > (l-1));
      close (f);

   //selecting versions

   if l = 0 then
   begin
      writeln ('no package ' + p + ' found');
      FindMatchingSrpm.name := 'not_found';
      j := nstringutils.npos ('-', p, 1);
      if j <> 0 then
      begin 
         if not (p[j+1] in ['0'..'9']) then
         begin
            s2 := nstringutils.LeftStr (p, j -1);
            if questions = true then
            begin
                  writeln ('should I try to find package ' + s2 + ' (y/n)?');
                  readln (s3);
                  if s3 <> 'n' then
                  begin
                     tmploc := FindMatchingSrpm (s2, v); 
	             FindMatchingSrpm.url := tmploc.url;
	             FindMatchingSrpm.name := tmploc.name;
		     if FindMatchingSrpm.name = 'not_found' then
		     begin
		       writeln ('no matching version found. try update your srpm sources urls');
                       halt;
                     end;
                     exit;
                  end;
            end;
            if questions = false then
            begin
               tmploc := FindMatchingSrpm (s2, v); 
	       FindMatchingSrpm.url := tmploc.url;
	       FindMatchingSrpm.name := tmploc.name;
	       if FindMatchingSrpm.name = 'not_found' then
	       begin
	          writeln ('no matching version found. try update your srpm sources urls');
                  halt;
               end;
               exit;
            end;
         end;
      end;  
      writeln ('no matching version found. try update your srpm sources urls');
      halt;
   end;

   if l > 1 then
   begin
          t := l;
          setlength(compver, t+1);
          writeln ('available versions of ' + p + ' source');
          for i := 1 to t do
          begin
             temptype := sourcearray[i];
             writeln (inttostr(i) +  '   ' + temptype.version + ' type: ' + 
                        temptype.tesak  + '   available at ' + temptype.url );
             compver[i] := temptype.version ;   
          end;
//          write ('selecting latest version: ');
          rrr := (compver[1]);
          rr := t;
          for i := 2 to t do
          begin
//             writeln ('is ' + compver[i] + ' >= ' + rrr);
             if ((compver[i]) >=  (rrr)) then
             begin
               rrr := compver[i];
               rr := i;
             end;
          end;
//       writeln (rr);
         if questions = true then
         begin
            writeln ('found several versions of ' + p + ' package');
//            writeln ('recommended version : ' + inttostr(rr));
            writeln ('please, select one: ');
            correct := false;
            repeat
               readln ( r );
               if (not (r in ['1'..'9'])) or (strtoint(r) > t) or (strtoint(r) < 1) then
               begin
                  writeln ('please use only digits between 1 and ' + inttostr(t));
                  correct := false; 
               end
              else
               begin
                  correct := true;
               end;
            until correct = true;
            temptype := SourceArray[strtoint(r)];
            FindMatchingSrpm.url := temptype.url;
            FindMatchingSrpm.name := temptype.fullname;
          end;
          if questions = false then
          begin
             writeln ('automatically trying to choose latest version: ' + inttostr(rr));
             temptype := SourceArray[rr];
             FindMatchingSrpm.url := temptype.url;
             FindMatchingSrpm.name := temptype.fullname;
          end;

   end;
   
   if l = 1 then
   begin
         temptype := SourceArray[1];
         FindMatchingSrpm.url := temptype.url;
         FindMatchingSrpm.name := temptype.fullname;
   end;
   
   if force = false then
   begin
      if ShellUtils.installed (temptype2) then
      begin
         writeln ('package ' + temptype.name + ' already newest version');
         findmatchingsrpm.name := 'installed';
         exit;
      end;
   end;
   compver := nil;
   sourcearray := nil;
end;


function FindMatchingSrpm_all ( p : string; v : string) : itypes.location;

var f : textfile;
    link, s1, rrr : string;
    t, l, i : integer;
    s2, s3 : string;
    j : integer;

{
    versions : array of  string;
    links : array of string;
    names : array of string;
}
    compver : array of string;
    SourceArray : array of itypes.srcrpm;
    r : char;
    rr : integer;
    srpm : itypes.srcrpm;
    temptype : itypes.srcrpm;
    tmploc : itypes.location;    
    correct : boolean;

begin

s2 := '';
s3 := '';
j := 0;



FindMatchingSrpm_all.name := 'installed';

   if nstringutils.RightStr(p, length(iconsts.devel)) = iconsts.devel then
   begin
       delete (p, (length(p)-length(iconsts.devel)) + 1, length(iconsts.devel));
   end;

   if nstringutils.LeftStr(p, length(iconsts.usrbinpath)) = iconsts.usrbinpath then
   begin
         delete (p, 1, length(iconsts.usrbinpath));
   end;


   s1 := '';
   l := 0;
   i := 0;
   link := '';
   rrr := '0000';
   assign (f, SourcesDataFile);
   reset (f);
   repeat
      readln (f, s1);
      if     (copy(s1,1,length(p)) = p) and (s1[length(p)+1] = '-')  
         and (s1[length(p)+2] in ['0'..'9']) then 
      begin
         inc(l);
      end;   

   until EOF(f);

   close (f);
   // now we now how many packages with the p name is in the srpms_data_file
   setlength (SourceArray, l + 1);
   assign (f, ivars.SourcesDataFile);
   reset (f);
   //creating an array with versions to let user select version   
   repeat
      readln (f, s1);
      if     (Copy (s1, 1, length(http_prefix)) = http_prefix)
          or (Copy(s1, 1, length(ivars.DistDir)) = ivars.DistDir) 
          or (Copy (s1, 1, length(ftp_prefix)) = ftp_prefix) then 
      begin
        link := s1;
      end
     else
      begin
         srpm := info(s1);
         srpm.url := link;
         if srpm.name = p then
         begin
            inc(i);
            sourcearray[i] := srpm;
         end;
      end;
   until EOF(f) or (i > (l-1));
   close (f);

   //selecting versions

   if l = 0 then
   begin
      writeln ('no package ' + p + ' found');
      FindMatchingSrpm_all.name := 'not_found';
      j := nstringutils.npos ('-', p, 1);
      if j <> 0 then
      begin 
         if not (p[j+1] in ['0'..'9']) then
         begin
            s2 := nstringutils.LeftStr (p, j -1);
            if questions = true then
            begin
               writeln ('should I try to find package ' + s2 + ' (y/n)?');
               readln (s3);
               if s3 <> 'n' then
               begin
                  tmploc := findmatchingsrpm_all (s2, v); 
	          findmatchingsrpm_all.url := tmploc.url;
	          findmatchingsrpm_all.name := tmploc.name;
		  if findmatchingsrpm_all.name = 'not_found' then
		  begin
		     writeln ('no matching version found. try update your srpm sources urls');
//                   halt;
                     findmatchingsrpm_all.name := 'not_found';
                     exit;
                  end;
                  exit;
               end;
            end;
            if questions = false then
            begin
               tmploc := findmatchingsrpm_all (s2, v); 
	       FindMatchingSrpm_all.url := tmploc.url;
	       FindMatchingSrpm_all.name := tmploc.name;
	       if findmatchingsrpm_all.name = 'not_found' then
	       begin
	          writeln ('no matching version found. try update your srpm sources urls');
//                halt;
                  FindMatchingSrpm_all.name := 'not_found';
                  exit;
               end;
               exit;
            end;
         end;
      end;  
      writeln ('no matching version found. try update your srpm sources urls');
//    halt;
      FindMatchingSrpm_all.name := 'not_found';
      exit;
   end;

   if l > 1 then
   begin
      t := l;
      setlength(compver, t+1);
      writeln ('available versions of ' + p + ' source');
      for i := 1 to t do
      begin
         temptype := sourcearray[i];
         writeln (inttostr(i) +  '   ' + temptype.version + ' type: ' 
                + temptype.tesak  + '   available at ' + temptype.url );
         compver[i] := temptype.version ;   
      end;
//    write ('selecting latest version: ');
      rrr := (compver[1]);
      rr := t;
      for i := 2 to t do
      begin
//       writeln ('is ' + compver[i] + ' >= ' + rrr);
         if ((compver[i]) >=  (rrr)) then
         begin
            rrr := compver[i];
            rr := i;
         end;
      end;
//    writeln (rr);
//end;
//   if l > 1 then 
//      begin
      if questions = true then
      begin
         writeln ('found several versions of ' + p);
//       writeln ('recommended version : ' + inttostr(rr));
         writeln ('please, select one: ');
         correct := false;
         repeat
            readln ( r );
            if (not (r in ['1'..'9'])) or (strtoint(r) > t) or (strtoint(r) < 1) then
            begin
               writeln ('please use only digits between 1 and ' + inttostr(t));
               correct := false; 
             end
            else
             begin
                correct := true;
             end;
         until correct = true;
         temptype := sourcearray[strtoint(r)];
         FindMatchingSrpm_all.url := temptype.url;
         FindMatchingSrpm_all.name := temptype.fullname;
      end;
      if questions = false then
      begin
         writeln ('automatically trying to choose latest version: ' + inttostr(rr));
         temptype := sourcearray[rr];
         FindMatchingSrpm_all.url := temptype.url;
         FindMatchingSrpm_all.name := temptype.fullname;
      end;
   end;
   if l = 1 then
   begin
      temptype := sourcearray[1];
      findmatchingsrpm_all.url := temptype.url;
      findmatchingsrpm_all.name := temptype.fullname;
   end;
{
versions := nil;
names := nil;
links := nil;
}
{
if installed (temptype) then
   begin
   writeln ('package ' + temptype.name + ' already newest version');
   findmatchingsrpm_all.name := 'installed';
   exit;
   end;
}
   compver := nil;
   sourcearray := nil;
end;

function StringcontainsSrcrpm (inp : string) : boolean;
var i : integer;
begin
   StringcontainsSrcrpm := false;
   i := 0;
   repeat
      inc (i);
      if Copy(inp, i, srcrpmextlen) = srcrpmext then 
      begin
         StringContainsSrcrpm := true;
      end;

      if Copy(inp, i, srcrpmextlen) = targzext then
      begin
         StringContainsSrcrpm := true;
      end;

      if Copy(inp, i, srcrpmextlen) = tarbzext then
      begin
         StringContainsSrcrpm := true;
      end;
   until (i = length(inp)) or (StringcontainsSrcrpm = true);
end;

function ExtractSrcrpmName ( inpu : string) : string;
var i, bareriqanak, j : integer;
strochka, strochka2 : string;
extracted : boolean;
begin
   strochka := '';
   strochka2 := '';
   ExtractSrcrpmName := '';
   bareriqanak := 0;
   i := 0;
   j := 0;
   bareriqanak := Word_Count(inpu, '"');
   extracted := false;
   repeat
   inc (i);
      strochka := extract_word (i, inpu, ['"']);
      strochka2 := nstringutils.RightStr(strochka, length (srcrpmext));
      if strochka2 = srcrpmext then 
      begin
         j := findlatestcharpos ('/', strochka);
         if j = 0 then extractsrcrpmname := strochka else extractsrcrpmname := copytillend(strochka, j + 1);
            extracted := true;
         end;
         strochka2 := nstringutils.RightStr(strochka, length (targzext));
         if strochka2 = targzext then
         begin
            j := findlatestcharpos ('/', strochka);
            if j = 0 then 
                extractsrcrpmname := strochka 
            else 
                extractsrcrpmname := copytillend(strochka, j + 1);
                extracted := true;
            end;
            strochka2 := nstringutils.RightStr(strochka, length (tarbzext));
            if strochka2 = tarbzext then
            begin
               j := findlatestcharpos ('/', strochka);
               if j = 0 then 
                   extractsrcrpmname := strochka 
               else 
                   extractsrcrpmname := copytillend(strochka, j + 1);
                   extracted := true;
               end;
   until extracted or (i = bareriqanak);

end;

end.

