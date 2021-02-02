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
*   Function FLINE_BLOCK_LEVEL (HIER)
*
*   Get the nesting level within the current block.  The top hierarchy level of
*   a block is at nesting level 0.
}
function fline_block_level (           {get nesting level within current block}
  in      hier: fline_hier_t)          {hierarchy level inquiring about}
  :sys_int_machine_t;                  {level within block, 0 = top of block}
  val_param;

begin
  fline_block_level := hier.blklev;
  end;
