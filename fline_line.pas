{   Routines for maniuplating individual lines of text.
}
module fline_line;
define fline_line_add_end;
define fline_line_virt;
define fline_line_virt_last;
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
  in      str: univ string_var_arg_t); {text string to add as a new line}
  val_param;

var
  line_p: fline_line_p_t;              {pointer to descriptor for the new line}

begin
  util_mem_grab (                      {allocate the line descriptor}
    sizeof(line_p^), fl.mem_p^, false, line_p);

  string_alloc (                       {allocate memory for the text line}
    str.len, fl.mem_p^, false, line_p^.str_p);
  string_copy (str, line_p^.str_p^);   {save copy of the text line}

  line_p^.next_p := nil;               {fill in fields in the line descriptor}
  line_p^.coll_p := addr(coll);
  line_p^.virt_p := nil;

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
{
********************************************************************************
*
*   Subroutine FLINE_LINE_VIRT (LINE, VCOLL, LNUM)
*
*   Add line number LNUM within collection VCOLL as the virtual reference from
*   the line LINE.
}
procedure fline_line_virt (            {add virtual reference to existing line}
  in out  line: fline_line_t;          {the line to add virtual reference to}
  in out  vcoll: fline_coll_t;         {collection being virtually referenced}
  in      lnum: sys_int_machine_t);    {line number within the collection}
  val_param;

var
  virt_p: fline_virtlin_p_t;           {pointer to new virtual line descriptor}

begin
  util_mem_grab (                      {allocate memory for the virtual line descriptor}
    sizeof(virt_p^),                   {amount of memory to allocate}
    vcoll.fline_p^.mem_p^,             {memory context}
    false,                             {won't individually deallocate}
    virt_p);                           {returned pointer to the new memory}

  virt_p^.coll_p := addr(vcoll);       {point to collection being virtually referenced}
  virt_p^.lnum := lnum;                {line number within that collection}

  line.virt_p := virt_p;               {point the line to its virtual reference}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_LINE_VIRT_LAST (COLL, VCOLL, LNUM)
*
*   Add the virtual reference to collection VCOLL at line LNUM to the last line
*   of the collection COLL.
}
procedure fline_line_virt_last (       {add virtual ref to last line of collection}
  in out  coll: fline_coll_t;          {add virt ref to last line of this coll}
  in out  vcoll: fline_coll_t;         {collection being virtually referenced}
  in      lnum: sys_int_machine_t);    {line number of virtual reference}
  val_param;

begin
  if coll.last_p = nil then return;    {there is no last line, nothing to do ?}
  fline_line_virt (coll.last_p^, vcoll, lnum);
  end;
