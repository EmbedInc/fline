module fline_hier;
define fline_hier_new;
define fline_hier_new_coll;
define fline_hier_new_line;
define fline_hier_create;
define fline_hier_delete;
define fline_hier_push_coll;
define fline_hier_push_line;
define fline_hier_push_file;
define fline_hier_pop;
define fline_hier_level;
define fline_hier_name;
define fline_hier_lnum;
define fline_hier_get_line;
define fline_hier_get_str;
define fline_hier_char;
define fline_hier_nextline;
define fline_hier_getnext_line;
define fline_hier_getnext_str;
define fline_hier_set_line_bef;
define fline_hier_set_line_at;
define fline_hier_set_line_aft;
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
  fline_hier_new (fl, parent_p, hier_p); {create new hier descriptor}
  fline_cpos_coll (hier_p^.cpos, coll); {init char pos to before start of collection}
  end;
{
********************************************************************************
*
*   Local subroutine FLINE_HIER_NEW_LINE (FL, PARENT_P, HIER_P, LINE)
*
*   Create a new hierarchy level, positioned to before the line LINE.  HIER_P
*   will point to the new hierarchy level.  When PARENT_P is NULL, then a new
*   top level hiearchy is created.  Otherwise, the new hierarchy level will
*   subordinate to the one pointed to by PARENT_P.
}
procedure fline_hier_new_line (        {create new hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {points to parent hierarchy level, if any}
  out     hier_p: fline_hier_p_t;      {returned pointing to new hierarchy level}
  in var  line: fline_line_t);         {line to set char position before start of}
  val_param;

begin
  fline_hier_new (fl, parent_p, hier_p); {create new hier descriptor}
  fline_cpos_set_line_bef (hier_p^.cpos, line); {init char pos to before start of line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH_COLL (FL, HIER_P, COLL)
*
*   Create a new subordinate hierarchy level, positioned to before the first
*   line of COLL.  HIER_P points to the parent hierarchy level on entry, and is
*   returned pointing to the newly-created child level.
}
procedure fline_hier_push_coll (       {new hierarchy level, connect to collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  coll: fline_coll_t);         {collection to read at the new level}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to new subordinate level}

begin
  fline_hier_new_coll (fl, hier_p, sub_p, coll); {create the new subordinate level}
  hier_p := sub_p;                     {return pointer to the new level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH_LINE (FL, HIER_P, LINE)
*
*   Create a new subordinate hierarchy level, positioned to before the start of
*   the line LINE.  HIER_P points to the parent hierarchy level on entry, and is
*   returned pointing to the newly-created child level.
}
procedure fline_hier_push_line (       {new hierarchy level, to before start of a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  line: fline_line_t);         {line to set char position before start of}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to new subordinate level}

begin
  fline_hier_new_line (fl, hier_p, sub_p, line); {create the new subordinate level}
  hier_p := sub_p;                     {return pointer to the new level}
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

  fline_file_get (                     {find or make collection for the file}
    fl,                                {library use state}
    fnam,                              {file name}
    coll_p,                            {returned pointer to file lines collection}
    stat);
  if sys_error(stat) then return;

  fline_hier_push_coll (fl, hier_p, coll_p^); {create subordinate level for the file lines}
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
*   Function FLINE_HIER_LEVEL (FL, HIER_P)
*
*   Get the nesting level of HIER.  The top level is 0, with each child level
*   one higher.  -1 is returned when there is no hiearchy (HIER_P is NIL).
}
function fline_hier_level (            {get hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      hier_p: fline_hier_p_t)      {pointer to hiearchy level inquiring about}
  :sys_int_machine_t;                  {nesting level, 0 at top, -1 for no hierarchy}
  val_param;

begin
  if hier_p = nil then begin           {there is no hiearchy ?}
    fline_hier_level := -1;
    return;
    end;
  fline_hier_level := hier_p^.level;   {return the 0-N hierarchy level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_NAME (FL, HIER, NAME_P)
*
*   Sets NAME_P pointing to the collection name for the hierarchy level HIER.
}
procedure fline_hier_name (            {get name of collection at a hier level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     name_p: univ string_var_p_t); {returned pointer to collection name}
  val_param;

begin
  name_p := univ_ptr(addr(fl.nullstr)); {init to return the empty string}
  if hier.cpos.line_p = nil then return; {no line here ?}
  if hier.cpos.line_p^.coll_p = nil then return; {no collection ?}

  name_p := hier.cpos.line_p^.coll_p^.name_p; {get pointer to the collection name}
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_LNUM (FL, HIER)
*
*   Get the sequential number of the current line of the hierarchy level HIER.
*   The first line in a collection is 1.  0 is returned when the position is
*   before the start of the collection.
}
function fline_hier_lnum (             {get line number at a hier level}
  in out  fl: fline_t;                 {FLINE library use state}
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
*   Subroutine FLINE_HIER_GET_LINE (HIER, LINE_P)
*
*   Get the pointer to the current line at the hierarchy level HIER.  LINE_P is
*   returned NIL if the position is before the start of the collection.
}
procedure fline_hier_get_line (        {get pointer to current line}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     line_p: fline_line_p_t);     {pointer to the line, NIL if before first}
  val_param;

begin
  line_p := hier.cpos.line_p;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_GET_STR (HIER, STR_P)
*
*   Set STR_P pointing to the text string for the current line of the hierarchy
*   level HIER.  STR_P is returned NIL when the position is before the start of
*   the collection of lines.
}
procedure fline_hier_get_str (         {get pointer to current line string}
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
*   Function FLINE_HIER_NEXTLINE (FL, HIER_P)
*
*   Advance to the next line in the hieararchy pointed to by HIER_P.  The
*   function returns TRUE when this is done successfully, and FALSE when the end
*   of all input is reached.  Hierarchy levels are automatically popped and
*   HIER_P updated accordingly when the ends of collections are reached.
}
function fline_hier_nextline (         {to next line in current hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t)      {pointer to position within hierarcy, may be updated}
  :boolean;                            {TRUE: advanced, not hit end of all input}
  val_param;

begin
  fline_hier_nextline := false;        {init to end of all input was reached}

  while true do begin                  {pop up as necessary to find next input line}
    if hier_p = nil then return;       {nothing left to read ?}
    if fline_cpos_nextline (hier_p^.cpos) then begin {went to new line in this collection ?}
      fline_hier_nextline := true;     {indicate at a new line}
      return;
      end;
    fline_hier_pop (fl, hier_p);       {pop this collection, up to parent}
    end;                               {back to try again at this new level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_GETNEXT_LINE (FL, HIER_P, LINE_P)
*
*   Advance to the next line in the hiearchy, and return LINE_P pointing to that
*   line.  Hierarchy levels are automatically popped and HIER_P updated
*   accordingly when the ends of collections are reached.
}
procedure fline_hier_getnext_line (    {advance to next input line in hier, return line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of all input}
  val_param;

begin
  if fline_hier_nextline (fl, hier_p) then begin {went to a new line ?}
    line_p := hier_p^.cpos.line_p;     {return pointer to the new line}
    return;
    end;
  line_p := nil;                       {no new line to go to}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_GETNEXT_STR (FL, HIER_P, STR_P)
*
*   Advance to the next line in the hiearchy, and return STR_P pointing to the
*   text of that line.  Hierarchy levels are automatically popped and HIER_P
*   updated accordingly when the ends of collections are reached.
}
procedure fline_hier_getnext_str (     {advance to next input line in hier, return string}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of all input}
  val_param;

begin
  str_p := nil;                        {init to no text available}

  if fline_hier_nextline (fl, hier_p) then begin {went to a new line ?}
    if hier_p^.cpos.line_p = nil then return;
    str_p := hier_p^.cpos.line_p^.str_p; {return pointer to text of new line}
    return;
    end;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_SET_LINE_BEF (FL, HIER_P, LINE)
*
*   Set the hierchy descriptor at HIER_P to the position immediately before the
*   start of the line LINE.  The existing position is overwritten and lost.
*
*   HIER_P can be NIL on entry.  If so, a new hierarchy is created and HIER_P
*   will be returned to the top (and only) level of the new hierarchy.
}
procedure fline_hier_set_line_bef (    {set position to immediately before a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  if hier_p = nil then begin           {no hierarchy exists ?}
    fline_hier_new (fl, nil, hier_p);  {create a new hierarchy, position not set yet}
    end;

  fline_cpos_set_line_bef (hier_p^.cpos, line); {got to before start of line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_SET_LINE_AT (FL, HIER_P, LINE)
*
*   Set the hierchy descriptor at HIER_P position to the start of the line LINE.
*   The existing position is overwritten and lost.
*
*   HIER_P can be NIL on entry.  If so, a new hierarchy is created and HIER_P
*   will be returned to the top (and only) level of the new hierarchy.
}
procedure fline_hier_set_line_at (     {set position to start of a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  if hier_p = nil then begin           {no hierarchy exists ?}
    fline_hier_new (fl, nil, hier_p);  {create a new hierarchy, position not set yet}
    end;

  fline_cpos_set_line_at (hier_p^.cpos, line); {got to start of line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_SET_LINE_AFT (FL, HIER_P, LINE)
*
*   Set the hierchy descriptor at HIER_P to the position immediately after the
*   end of the line LINE.  The existing position is overwritten and lost.
*
*   HIER_P can be NIL on entry.  If so, a new hierarchy is created and HIER_P
*   will be returned to the top (and only) level of the new hierarchy.
}
procedure fline_hier_set_line_aft (    {set position to immediately after a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  if hier_p = nil then begin           {no hierarchy exists ?}
    fline_hier_new (fl, nil, hier_p);  {create a new hierarchy, position not set yet}
    end;

  fline_cpos_set_line_aft (hier_p^.cpos, line); {got to before start of line}
  end;
