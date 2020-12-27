{   Routines for maniuplating individual lines of text.
}
module fline_line;
define fline_line_add_end;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_LINE_ADD_END (FL, COLL, LINE)
*
*   Add the text line LINE to the end of the collection COLL.
}
procedure fline_line_add_end (         {add line to end of collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  coll: fline_coll_t;          {the collection to add to}
  in      line: univ string_var_arg_t); {the text line to add}
  val_param;

var
  line_p: fline_line_p_t;              {pointer to descriptor for the new line}

begin
  util_mem_grab (                      {allocate the line descriptor}
    sizeof(line_p^), fl.mem_p^, false, line_p);

  string_alloc (                       {allocate memory for the text line}
    line.len, fl.mem_p^, false, line_p^.str_p);
  string_copy (line, line_p^.str_p^);  {save copy of the text line}

  line_p^.next_p := nil;               {fill in fields in the line descriptor}
  line_p^.coll_p := addr(coll);

  if coll.last_p = nil                 {link new line to the collection}
    then begin                         {this is first line in collection}
      line_p^.prev_p := nil;
      line_p^.lnum := 1;
      coll.first_p := line_p;
      end
    else begin                         {adding after existing lines}
      line_p^.prev_p := coll.last_p;
      line_p^.lnum := coll.last_p^.lnum + 1;
      coll.last_p^.next_p := line_p;
      end
    ;
  coll.last_p := line_p;
  end;
