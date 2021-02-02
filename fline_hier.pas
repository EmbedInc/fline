module fline_hier;
define fline_hier_new;
define fline_hier_create;
define fline_hier_delete;
define fline_hier_push;
define fline_hier_push_file;
define fline_hier_pop;
define fline_hier_level;
define fline_hier_name;
define fline_hier_lnum;
define fline_hier_line;
define fline_hier_linenx;
define fline_hier_line_str;
define fline_hier_char;
define fline_hier_nextline;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_HIER_NEW (FL, PARENT_P, HIER_P)
*
*   Create a new empty hierarchy level.  PARENT_P points to the parent hierarchy
*   level, if any.  When PARENT_P is NIL, then a new top level will be created.
*
*   The new hierarchy level is linked to the parent (when appropriate) and
*   otherwise initialized to default or benign values.  Not specific character
*   position will be filled in.
}
procedure fline_hier_new (             {low level routine to create new hierchy descriptor}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {pointer to parent, NIL for create top level}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level, CPOS not filled in}
  val_param;

begin
  util_mem_grab (                      {allocate new hiearchy level descriptor}
    sizeof(hier_p^),                   {amount of memory to allocate}
    fl.mem_p^,                         {memory context}
    true,                              {allow deallocation}
    hier_p);                           {returned pointer to the new memory}

  hier_p^.prev_p := parent_p;          {point to parent level, if any}

  if parent_p = nil
    then begin                         {creating top level}
      hier_p^.level := 0;
      hier_p^.blklev := 0;
      end
    else begin                         {creating subordinate level}
      hier_p^.level := parent_p^.level + 1;
      hier_p^.blklev := parent_p^.blklev + 1;
      end
    ;

  fline_cpos_init (hier_p^.cpos);      {init char position to default or benign values}
  end;
{
********************************************************************************
*
*   Local subroutine FLINE_HIER_NEW_COLL (FL, PARENT_P, HIER_P, COLL)
*
*   Create a new hierarchy level for the collection of lines COLL.  HIER_P will
*   point to the new hierarchy level.  When PARENT_P is NULL, then a new top
*   level hiearchy is created.  Otherwise, the new hierarchy level will
*   subordinate to the one pointed to by PARENT_P.
}
procedure fline_hier_new_coll (        {create new hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {points to parent hierarchy level, if any}
  out     hier_p: fline_hier_p_t;      {returned pointing to new hierarchy level}
  in var  coll: fline_coll_t);         {collection of lines new level will refer to}
  val_param;

begin
  fline_hier_new (coll.fline_p^, parent_p, hier_p); {create new hier descriptor}
  fline_cpos_coll (hier_p^.cpos, coll); {init char pos to before start of collection}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_CREATE (FL, HIER_P, COLL)
*
*   Create a new hierarchy for reading nested "files".  The top level of the
*   hierarchy is created, with HIER_P returned pointing to it.  This top level
*   will be connected to the collection COLL, and initialized to before the
*   start of the collection.
}
procedure fline_hier_create (          {create a new files hierarchy stack}
  in out  fl: fline_t;                 {FLINE library use state}
  out     hier_p: fline_hier_p_t;      {returned pointer to top level of new hierarchy}
  in var  coll: fline_coll_t);         {collection for top "file" of hierarchy}
  val_param;

begin
  fline_hier_new_coll (fl, nil, hier_p, coll);
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_DELETE (FL, HIER_P)
*
*   Delete the hierarchy pointed to by HIER_P, which is returned NIL.  All
*   hierarchy levels from the one pointed to by HIER_P to the top level will be
*   deleted.
}
procedure fline_hier_delete (          {delete whole hierarchy}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {delete this level and all parents, returned NIL}
  val_param;

begin
  while hier_p <> nil do begin         {pop levels until nothing left}
    fline_hier_pop (fl, hier_p);
    end;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH (FL, HIER_P, COLL)
*
*   Create a new subordinate hierarchy level, connected to the collection COLL.
*   HIER_P points to the parent hierarchy level on entry, and is returned
*   pointing to the newly-created child level.  The position will be before the
*   start of COLL.
}
procedure fline_hier_push (            {new hierarchy level, connect to collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  coll: fline_coll_t);         {collection to read at the new level}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to new subordinate level}

begin
  if hier_p = nil then return;         {no existing level, nothing to do ?}

  fline_hier_new_coll (fl, hier_p, sub_p, coll); {create the new subordinate level}
  hier_p := sub_p;                     {return pointer to the new level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH_FILE (FL, HIER_P, FNAM, STAT)
*
*   Create a new subordinate hierarchy level, connected to the lines of the file
*   FNAM.  A collection for the lines of file FNAME will be created if not
*   previously existing.  HIER_P points to the parent hierarchy level on entry,
*   and is returned pointing to the newly-created child level.  The position
*   will be before the start of the lines of file FNAM.
}
procedure fline_hier_push_file (       {new hierarchy level, connect to coll of a file}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in      fnam: univ string_var_arg_t; {name of file to read at the new level}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  coll_p: fline_coll_p_t;              {pointer to lines of the indicated file}

begin
  sys_error_none (stat);               {init to no error encountered}
  if hier_p = nil then return;         {no existing level, nothing to do ?}

  fline_file_get (                     {find or make collection for the file}
    hier_p^.cpos.coll_p^.fline_p^,     {library use state}
    fnam,                              {file name}
    coll_p,                            {returned pointer to file lines collection}
    stat);
  if sys_error(stat) then return;

  fline_hier_push (fl, hier_p, coll_p^); {create subordinate level for the file lines}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_POP (FL, HIER_P)
*
*   Pop up one level from the hierarchy level pointed to by HIER_P.  The
*   original level will be deleted, with HIER_P returned pointing to the parent
*   level.  HIER_P is returned NIL when the top level is popped.
}
procedure fline_hier_pop (             {pop back to previous hier level, delete old}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {will point to parent, NIL when popped top level}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to subordinate level to delete}

begin
  if hier_p = nil then return;         {nothing to pop ?}
  sub_p := hier_p;                     {save pointer to level to delete}
  hier_p := hier_p^.prev_p;            {return pointing to parent level}

  util_mem_ungrab (sub_p, fl.mem_p^);  {deallocate this hierarchy level}
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_LEVEL (HIER)
*
*   Get the nesting level of HIER.  The top level is 0, with each child level
*   one higher.
}
function fline_hier_level (            {get hierarchy level}
  in      hier: fline_hier_t)          {descriptor for the hierarchy level}
  :sys_int_machine_t;                  {nesting level, 0 at top}
  val_param;

begin
  fline_hier_level := hier.level;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_NAME (HIER, NAME_P)
*
*   Sets NAME_P pointing to the collection name for the hierarchy level HIER.
}
procedure fline_hier_name (            {name of collection at a hier level}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     name_p: string_var_p_t);     {returned pointer to collection name}
  val_param;

begin
  name_p := hier.cpos.coll_p^.name_p;  {get pointer to the collection name}
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_LNUM (HIER)
*
*   Get the sequential number of the current line of the hierarchy level HIER.
*   The first line in a collection is 1.  0 is returned when the position is
*   before the start of the collection.
}
function fline_hier_lnum (             {get line number at a hier level}
  in      hier: fline_hier_t)          {descriptor for the hierarchy level}
  :sys_int_machine_t;                  {1-N line number, 0 before first}
  val_param;

begin
  if hier.cpos.line_p = nil then begin {before start of collection ?}
    fline_hier_lnum := 0;
    return;
    end;

  fline_hier_lnum := hier.cpos.line_p^.lnum; {return the current line number}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_LINE (HIER, LINE_P)
*
*   Get the pointer to the current line at the hierarchy level HIER.  LINE_P is
*   returned NIL if the position is before the start of the collection.
}
procedure fline_hier_line (            {get pointer to current line at a hier level}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     line_p: fline_line_p_t);     {pointer to the line, NIL if before first}
  val_param;

begin
  line_p := hier.cpos.line_p;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_LINENX (HIER, LINE_P)
*
*   Get the pointer to the next line at the hierarchy level HIER.  LINE_P is
*   returned NIL if the position is before the start of the collection.
}
procedure fline_hier_linenx (          {get pointer to next line at a hier level}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     line_p: fline_line_p_t);     {pointer to the next line, NIL if before first}
  val_param;

begin
  if hier.cpos.line_p = nil
    then begin                         {before start of collection}
      line_p := hier.cpos.coll_p^.first_p;
      end
    else begin                         {at an actual line}
      line_p := hier.cpos.line_p^.next_p;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_LINE_STR (HIER, STR_P)
*
*   Set STR_P pointing to the text string for the current line of the hierarchy
*   level HIER.  STR_P is returned NIL when the position is before the start of
*   the collection of lines.
}
procedure fline_hier_line_str (        {get current line string at a hier level}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     str_p: string_var_p_t);      {pointer to line string, NIL if before first}
  val_param;

begin
  if hier.cpos.line_p = nil then begin {before start of collection ?}
    str_p := nil;
    return;
    end;

  str_p := hier.cpos.line_p^.str_p;    {return pointer to text for this line}
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_CHAR (HIER, CH)
*
*   Get the current character into CH, then advance the position to the next
*   character.  The function returns TRUE when there is a character and the
*   position was advanced.
*
*   The function returns FALSE when the position is at the end of a line.  In
*   that case, CH is returned NULL (character code 0), and the position is not
*   changed.
}
function fline_hier_char (             {get current character, advance to next}
  in out  hier: fline_hier_t;          {position within hierarchy, updated to next char}
  out     ch: char)                    {returned character, 0 for none}
  :boolean;                            {TRUE: returning char, FALSE: end of line}
  val_param;

begin
  fline_hier_char := fline_char (hier.cpos, ch);
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_NEXTLINE (HIER)
*
*   Advance the current position of the hierarchy level HIER to the start of the
*   next line.  The function returns TRUE when this is done successfully.  When
*   the position was already at the end of the collection, then the function
*   returns FALSE and the position is not altered.
}
function fline_hier_nextline (         {to next line in current hierarchy level}
  in out  hier: fline_hier_t)          {position within hierarchy, updated to start of next line}
  :boolean;                            {TRUE: advanced, not hit end of collection}
  val_param;

begin
  fline_hier_nextline := fline_cpos_nextline (hier.cpos);
  end;
