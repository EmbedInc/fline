{   Routines that manage blocks within a hierarchy of nested streams.  Blocks
*   are delineated contiguous regions within a larger hierarchy.  Levels within
*   a block have their own level number, in addition to the global level number.
}
module fline_block;
define fline_block_new_copy;
define fline_block_new_line;
define fline_block_pop;
define fline_block_delete;
define fline_block_level;
define fline_block_nextline;
define fline_block_getnext_line;
define fline_block_getnext_str;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Local subroutine FLINE_BLOCK_NEW (FL, PARENT, HIER_P)
*
*   Create a new level within an existing hierarchy that will be the top of a
*   new block.  The character position is initialized to default or benign
*   values, but not set.
*
*   PARENT is the hierarchy level that the new block will be subordinate to.
}
procedure fline_block_new (            {create new blank start of block hier level}
  in out  fl: fline_t;                 {FLINE library use state}
  in var  parent: fline_hier_t;        {parent hierarchy level}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level, CPOS not filled in}
  val_param;

begin
  fline_hier_new (fl, addr(parent), hier_p); {create new blank hiearchy level}
  hier_p^.blklev := 0;                 {this level is at top of new block}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_NEW_COPY (FL, PARENT, HIER_P)
*
*   Start a new hiearchy block.  The current character position will be copied
*   from the parent.  HIER_P is returned pointing to the new hiearchy
*   descriptor.
}
procedure fline_block_new_copy (       {start hier block, copy original position}
  in out  fl: fline_t;                 {FLINE library use state}
  in var  parent: fline_hier_t;        {hierarchy position to make copy of}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level}
  val_param;

begin
  fline_block_new (                    {create the new descriptor}
    fl,                                {library use state}
    parent,                            {parent hierarchy level}
    hier_p);                           {returned pointer to top of new block}

  hier_p^.cpos := parent.cpos;         {init character position same as parent}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_NEW_LINE (FL, PARENT, LINE, HIER_P)
*
*   Start a new hiearchy block.  The character position will be the start of the
*   line LINE.
}
procedure fline_block_new_line (       {start hier block at specific line}
  in out  fl: fline_t;                 {FLINE library use state}
  in var  parent: fline_hier_t;        {parent hierarchy position}
  in var  line: fline_line_t;          {position will be at start of this line}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level}
  val_param;

begin
  fline_block_new (                    {create the new descriptor}
    fl,                                {library use state}
    parent,                            {parent hierarchy level}
    hier_p);                           {returned pointer to top of new block}

  fline_cpos_line (hier_p^.cpos, line); {set char position to start of this line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_POP (FL, HIER_P)
*
*   Pop one hiearchy level, but only within the current block.  NIL is returned
*   when the top level of the block is popped.
}
procedure fline_block_pop (            {pop back one level within hierarchy block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {will point to parent, NIL popped from top of block}
  val_param;

var
  lev: sys_int_machine_t;              {start level within block}

begin
  if hier_p = nil then return;         {nothing to pop ?}

  lev := hier_p^.blklev;               {save current level within block}
  fline_hier_pop (fl, hier_p);         {pop off the current level, go to parent}
  if lev = 0 then hier_p := nil;       {block now completely deleted ?}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_DELETE (FL, HIER_P)
*
*   Pop all the levels in the current block.  HIER_P is returned pointing to the
*   parent of the top level of the block.  All levels of the current block are
*   deleted.  HIER_P is returned NIL when the top block is popped.
}
procedure fline_block_delete (         {delete entire current block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {ret first lev above block, NIL deleted top block}
  val_param;

var
  lev: sys_int_machine_t;              {start level within block}

begin
  if hier_p = nil then return;         {nothing to pop ?}

  repeat
    lev := hier_p^.blklev;             {get level within current block}
    fline_hier_pop (fl, hier_p);       {pop and delete this current level}
    until lev = 0;                     {popped top level of block ?}
  end;
{
********************************************************************************
*
*   Function FLINE_BLOCK_LEVEL (HIER_P)
*
*   Get the nesting level within the current block.  The top hierarchy level of
*   a block is at nesting level 0.
}
function fline_block_level (           {get nesting level within current block}
  in      hier_p: fline_hier_p_t)      {pointer to hiearchy level inquiring about}
  :sys_int_machine_t;                  {nesting level, 0 at block top, -1 for no hierarchy}
  val_param;

begin
  if hier_p = nil then begin
    fline_block_level := -1;
    return;
    end;

  fline_block_level := hier_p^.blklev;
  end;
{
********************************************************************************
*
*   Function FLINE_BLOCK_NEXTLINE (FL, HIER_P)
*
*   Advance to the next line in the current block.  The function returns TRUE
*   when this is done successfully, and FALSE when the end of the input for the
*   block is reached.  Hierarchy levels are automatically popped and HIER_P
*   updated accordingly when the ends of collections are reached.
}
function fline_block_nextline (        {to next line in current block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t)      {pointer to position within hierarcy, may be updated}
  :boolean;                            {TRUE: advanced, not hit end of block}
  val_param;

begin
  fline_block_nextline := false;       {init to end of block was reached}

  while true do begin                  {pop up as necessary to find next input line}
    if hier_p = nil then return;       {nothing left to read ?}
    if fline_cpos_nextline (hier_p^.cpos) then begin {went to new line in this collection ?}
      fline_block_nextline := true;    {indicate at a new line}
      return;
      end;
    if hier_p^.blklev = 0 then return; {reached end of input this block }
    fline_hier_pop (fl, hier_p);       {pop this collection, up to parent}
    end;                               {back to try again at this new level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_GETNEXT_LINE (FL, HIER_P, LINE_P)
*
*   Advance to the next line in the current block, and return LINE_P pointing to
*   that line.  Hierarchy levels are automatically popped and HIER_P updated
*   accordingly when the ends of collections are reached.
}
procedure fline_block_getnext_line (   {advance to next input line in block, return line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of block}
  val_param;

begin
  if fline_block_nextline (fl, hier_p) then begin {went to a new line ?}
    line_p := hier_p^.cpos.line_p;     {return pointer to the new line}
    return;
    end;
  line_p := nil;                       {no new line to go to}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_BLOCK_GETNEXT_STR (FL, HIER_P, STR_P)
*
*   Advance to the next line in the current block, and return STR_P pointing to
*   the text of that line.  Hierarchy levels are automatically popped and HIER_P
*   updated accordingly when the ends of collections are reached.
}
procedure fline_block_getnext_str (    {advance to next input line in block, return string}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of block}
  val_param;

begin
  str_p := nil;                        {init to no text available}

  if fline_block_nextline (fl, hier_p) then begin {went to a new line ?}
    if hier_p^.cpos.line_p = nil then return; {no current line (shouldn't happen) ?}
    str_p := hier_p^.cpos.line_p^.str_p; {return pointer to text of new line}
    return;
    end;
  end;
