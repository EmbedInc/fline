{   Routines for maniuplating individual lines of text.
}
module fline_line;
define fline_line_add_end;
define fline_line_virt;
define fline_line_virt_last;
define fline_line_lnum;
define fline_line_lnum_virt;
define fline_line_name;
define fline_line_name_virt;
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
{
********************************************************************************
*
*   Function FLINE_LINE_LNUM (LINE)
*
*   Get the line number of the line LINE.
}
function fline_line_lnum (             {get number of a line within collection}
  in out  line: fline_line_t)          {the line inquiring about}
  :sys_int_machine_t;                  {1-N line number, 0 before start}
  val_param;

begin
  fline_line_lnum := line.lnum;
  end;
{
********************************************************************************
*
*   Function FLINE_LINE_LNUM_VIRT (LINE)
*
*   Get the virtual line number of the line LINE.  If there is no virtual
*   location defined for this line, then the real line number is returned.
}
function fline_line_lnum_virt (        {get number of a line within virtual collection}
  in out  line: fline_line_t)          {the line inquiring about}
  :sys_int_machine_t;                  {1-N line number, 0 before start}
  val_param;

begin
  if line.virt_p <> nil then begin     {there is a vitual line ?}
    fline_line_lnum_virt := line.virt_p^.lnum; {get virtual line number}
    return;
    end;

  fline_line_lnum_virt := line.lnum;   {get the real line number}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_LINE_NAME (LINE, NAME_P)
*
*   Get the name of the collection containing the line LINE.  NAME_P is returned
*   pointing to the name.
}
procedure fline_line_name (            {get name of collection that line is in}
  in out  line: fline_line_t;          {the line inquiring about}
  out     name_p: string_var_p_t);     {returned pointing to collection name}
  val_param;

begin
  name_p := nil;                       {init to no name available}
  if line.coll_p = nil then return;    {no collection indicated ?}
  name_p := line.coll_p^.name_p;       {return pointer to collection name}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_LINE_NAME_VIRT (LINE, NAME_P)
*
*   Get the name of the virtual collection the line LINE is within.  NAME_P is
*   returned pointing to the name.  If there is no virtual location defined for
*   the line, then the name of the real collection is returned.
}
procedure fline_line_name_virt (       {get name of virtual collection that line is in}
  in out  line: fline_line_t;          {the line inquiring about}
  out     name_p: string_var_p_t);     {returned pointing to collection name}
  val_param;

begin
  name_p := nil;                       {init to no name available}
  if                                   {virtual name is available ?}
      (line.virt_p <> nil) and then    {virtual location exists ?}
      (line.virt_p^.coll_p <> nil) and then {virtual collection is known ?}
      (line.virt_p^.coll_p^.name_p <> nil) {the virtual collection has a name ?}
      then begin
    name_p := line.virt_p^.coll_p^.name_p; {return the virtual collection name}
    return;
    end;

  if line.coll_p = nil then return;    {no real collection indicated ?}
  name_p := line.coll_p^.name_p;       {return pointer to real collection name}
  end;
