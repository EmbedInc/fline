module fline_hier;
define fline_hier_create;
define fline_hier_delete;
define fline_hier_push;
define fline_hier_push_file;
define fline_hier_pop;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Local ubroutine FLINE_HIER_NEW (PARENT_P, SUB_P, COLL)
*
*   Create a new hierarchy level for the collection of lines COLL.  SUB_P will
*   point to the new hierarchy level.  When PARENT_P is NULL, then SUB_P will be
*   the top level of a new hierarchy.  Otherwise, the new hierarchy level will
*   subordinate to the one pointed to by PARENT_P.
}
procedure fline_hier_new (             {create new hierarchy level}
  in      parent_p: fline_hier_p_t;    {points to parent hierarchy level, if any}
  out     sub_p: fline_hier_p_t;       {returned pointing to new hierarchy level}
  in var  coll: fline_coll_t);         {collection of lines new level will refer to}
  val_param;

begin
  util_mem_grab (                      {allocate memory for top hierarchy level}
    sizeof(sub_p^),                    {amount of memory to allocate}
    coll.fline_p^.mem_p^,              {memory context}
    true,                              {allow deallocation}
    sub_p);                            {returned pointer to the new memory}

  sub_p^.prev_p := parent_p;           {point to parent hierarchy level, if any}

  if parent_p = nil
    then begin                         {creating top level}
      sub_p^.level := 0;
      end
    else begin                         {creating subordinate level}
      sub_p^.level := parent_p^.level + 1;
      end
    ;

  fline_pos_start (coll, sub_p^.pos);  {init to before start of collection}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_CREATE (HIER_P, COLL)
*
*   Create a new hierarchy for reading nested "files".  The top level of the
*   hierarchy is created, with HIER_P returned pointing to it.  This top level
*   will be connected to the collection COLL, and initialized to before the
*   start of the collection.
}
procedure fline_hier_create (          {create a new files hierarchy stack}
  out     hier_p: fline_hier_p_t;      {returned pointer to top level of new hierarchy}
  in var  coll: fline_coll_t);         {collection for top "file" of hierarchy}
  val_param;

begin
  fline_hier_new (nil, hier_p, coll);
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_DELETE (HIER_P)
*
*   Delete the hierarchy pointed to by HIER_P, which is returned NIL.  All
*   hierarchy levels from the one pointed to by HIER_P to the top level will be
*   deleted.
}
procedure fline_hier_delete (          {delete whole hierarchy}
  in out  hier_p: fline_hier_p_t);     {delete this level and all parents, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {pointer to mem context for all hier levels}
  curr_p: fline_hier_p_t;              {pointer to current hierarchy level}
  prev_p: fline_hier_p_t;              {pointer to next higher hierarchy level}

begin
  if hier_p = nil then return;         {nothing to do ?}

  mem_p := hier_p^.pos.coll_p^.fline_p^.mem_p; {get pointer to memory context}

  prev_p := hier_p;                    {init prev hierarchy level}
  repeat                               {up the hierarchy levels}
    curr_p := prev_p;                  {get pointer to hierarchy level to delete}
    prev_p := curr_p^.prev_p;          {save pointer to previous level}
    util_mem_ungrab (curr_p, mem_p^);  {deallocate descriptor for this level}
    until prev_p = nil;                {back for next level up, if there is one}

  hier_p := nil;                       {return invalid pointer}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH (HIER_P, COLL)
*
*   Create a new subordinate hierarchy level, connected to the collection COLL.
*   HIER_P points to the parent hierarchy level on entry, and is returned
*   pointing to the newly-created child level.  The position will be before the
*   start of COLL.
}
procedure fline_hier_push (            {new hierarchy level, connect to collection}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  coll: fline_coll_t);         {collection to read at the new level}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to new subordinate level}

begin
  if hier_p = nil then return;         {no existing level, nothing to do ?}

  fline_hier_new (hier_p, sub_p, coll); {create the new subordinate level}
  hier_p := sub_p;                     {return pointer to the new level}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_HIER_PUSH_FILE (HIER_P, FNAM, STAT)
*
*   Create a new subordinate hierarchy level, connected to the lines of the file
*   FNAM.  A collection for the lines of file FNAME will be created if not
*   previously existing.  HIER_P points to the parent hierarchy level on entry,
*   and is returned pointing to the newly-created child level.  The position
*   will be before the start of the lines of file FNAM.
}
procedure fline_hier_push_file (       {new hierarchy level, connect to coll of a file}
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
    hier_p^.pos.coll_p^.fline_p^,      {library use state}
    fnam,                              {file name}
    coll_p,                            {returned pointer to file lines collection}
    stat);
  if sys_error(stat) then return;

  fline_hier_push (hier_p, coll_p^);   {create subordinate level for the file lines}
  end;
{
********************************************************************************
*
*   Function FLINE_HIER_POP (HIER_P)
*
*   Pop up one level from the hierarchy level pointed to by HIER_P.  The
*   original level will be deleted, with HIER_P returned pointing to the parent
*   level.
*
*   If already at the top level, then nothing is altered and the function
*   returns FALSE.  The function returns TRUE in the normal case where the
*   existing level was deleted and HIER_P is returned pointing to the parent
*   level.
}
function fline_hier_pop (              {pop back to previous hier level, delete old}
  in out  hier_p: fline_hier_p_t)      {pnt to curr level, will point to parent}
  :boolean;                            {popped, not at top level}
  val_param;

var
  sub_p: fline_hier_p_t;               {pointer to subordinate level to delete}

begin
  fline_hier_pop := false;             {init to level popped unsuccessfully}
  if hier_p = nil then return;         {no valid input, nothing to do ?}
  if hier_p^.prev_p = nil then return; {already at top level ?}

  sub_p := hier_p;                     {save pointer to level to delete}
  hier_p := hier_p^.prev_p;            {return pointing to parent level}
  fline_hier_pop := true;              {indicate level popped successfully}

  fline_hier_delete (sub_p);           {delete the subordinate level}
  end;
