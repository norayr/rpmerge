unit parse;

interface

procedure extractlinks ( input_file : string ; output_file : string);


implementation

uses iconsts, srcrpms, unix;

procedure extractlinks ( input_file : string ; output_file : string);
var ifile : textfile;
    togh, srcrpmname : string;
begin

togh := '';
srcrpmname := '';

assign (ifile, input_file);
reset(ifile);

   repeat
   readln (ifile, togh);
   if togh<>'' then
   begin
      if srcrpms.StringContainsSrcrpm (togh) = true then
         begin
         srcrpmname := extractsrcrpmname(togh);
         Shell ('echo "' + srcrpmname + '" >> ' + output_file);
         end;
   end;
   until EOF(ifile);
close(ifile);


end;



end.
