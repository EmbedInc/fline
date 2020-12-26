{   High level library management.
}
module fline_lib;
define fline_new;
define fline_end;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_NEW (MEM, FLINE_P, STAT)
*
*   Start a new use of the FLINE library.  MEM is the parent memory context.  A
*   subordinate context will be created for the exclusive use of the new FLINE
*   library use.
*
*   On no error, FLINE_P is returned pointing to the new library use state, and
*   STAT is set to no error.
*
*   On error, FLINE_P is returned NIL, and STAT indicates the error.
}
procedure fline_new (                  {create new use of the FLINE library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     fline_p: fline_p_t;          {returned pointer to new library use state}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  mem_p: util_mem_context_p_t;         {pointer to new private memory context}

begin
  fline_p := nil;                      {init to new use not created}

  util_mem_context_get (mem, mem_p);   {create mem context for the new use}
  if util_mem_context_err (mem_p, stat) {error getting the mem context ?}
    then return;

  util_mem_grab (                      {allocate descriptor for new lib use}
    sizeof(fline_p^),                  {amount of memory to allocate}
    mem_p^,                            {memory context to allocate under}
    false,                             {will not individually deallocate this}
    fline_p);                          {returned pointer to the new memory}
  if util_mem_grab_err (fline_p, sizeof(fline_p^), stat) {error getting the memory ?}
    then return;

  fline_p^.mem_p := mem_p;             {save pointer to mem context for this lib use}
  fline_p^.coll_first_p := nil;
  fline_p^.coll_last_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_END (FLINE_P)
*
*   End a use of the FLINE library.  FLINE_P must point to the FLINE library use
*   state on entry.  It will be returned NIL.
}
procedure fline_end (                  {end a use of the FLINE library}
  in out  fline_p: fline_p_t);         {pointer to lib use state, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {pointer to mem context for the lib use}

begin
  if fline_p = nil then return;        {ignore request if no library use state}

  mem_p := fline_p^.mem_p;             {make local copy of pointer to mem context}
  util_mem_context_del (mem_p);        {deallocate all dyn mem, delete context}

  fline_p := nil;                      {return lib use state pointer invalid}
  end;
