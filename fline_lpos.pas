{   Routines that deal with the dynamic and permanent logical postion
*   descriptors.
}
module fline_lpos;
define fline_lpos_push;
define fline_lpos_pop;
define fline_lpos_perm;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_LPOS_PUSH (FL, LPDYN_P, LINE_P)
*
*   Add a new lower level to the dynamic logical position hierarchy pointed to
*   by LPDYN_P.  LPDYN_P is returned pointing to the new level.  LPDYN_P may be
*   NIL on entry, in which case a new hierarchy is created.  LINE_P points to
*   the line to reference at the new child hierarchy level.
*
*   The new logical position hierarchy level will be dynamic, and will be
*   deleted when that level is popped (see FLINE_LPOS_POP).  Pointers to dynamic
*   descriptors should not be stored in permanent structures.  Use
*   FLINE_LPOS_PERM to create a permanent copy of the logical hierarcy position.
}
procedure fline_lpos_push (            {create new nested layer in dyn logical position}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  lpdyn_p: fline_lposdyn_p_t;  {parent pos, may be NIL, returned pointing to new}
  in      line_p: fline_line_p_t);     {line of the new nested layer}
  val_param;

var
  pos_p: fline_lposdyn_p_t;            {pointer to the new descriptor}

begin
  util_mem_grab (                      {allocate the memory for the new descriptor}
    sizeof(pos_p^), fl.mem_p^, true, pos_p);
  pos_p^.prev_p := lpdyn_p;            {link to parent level}
  pos_p^.line_p := line_p;             {reference the specific text line}
  pos_p^.perm_p := nil;                {init to no permanent descriptor allocated}

  lpdyn_p := pos_p;                    {update the caller's pointer to the new descriptor}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_LPOS_POP (FL, LPDYN_P)
*
*   Remove the dynamic logical hierarchy level pointed to by LPDYN_P, and return
*   LPDYN_P pointing to the parent hierarchy level.  LPDYN_P is returned NIL
*   when there is no parent level (LPDYN_P originally pointed to the top level).
}
procedure fline_lpos_pop (             {pop up one dynamic logical position level}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  lpdyn_p: fline_lposdyn_p_t); {pnt to level to pop, returned parent, NIL at top}
  val_param;

var
  pos_p: fline_lposdyn_p_t;            {pointer to the descriptor being deleted}

begin
  if lpdyn_p = nil then return;        {no descriptor, nothing to do ?}

  pos_p := lpdyn_p;                    {save pointer to the descriptor to delete}
  lpdyn_p := lpdyn_p^.prev_p;          {return caller's pointer to parent level}

  util_mem_ungrab (pos_p, fl.mem_p^);  {delete the child descriptor}
  end;
{
********************************************************************************
*
*   Local subroutine FLINE_LPOS_PERM (FL, LPDYN)
*
*   Make sure that a permanent descriptor exists for the dynamic logical
*   position LPDYN and all its parent levels.  Permanent descriptor are
*   allocated, if not already existing.  When this routine returns, LPDYN.PERM_P
*   is guaranteed to be pointing to a chain of permanent descriptors.
}
procedure fline_lpos_perm (            {make sure permanent descriptor exists}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  lpdyn: fline_lposdyn_t);     {dynamic descriptor to make permanent copy of}
  val_param;

begin
  if lpdyn.perm_p <> nil then return;  {perm descriptors already exist here and above ?}

  if lpdyn.prev_p <> nil then begin    {make sure the parent levels all have perms}
    fline_lpos_perm (fl, lpdyn.prev_p^);
    end;

  util_mem_grab (                      {allocate mem for the permanent descriptor}
    sizeof(lpdyn.perm_p^), fl.mem_p^, false, lpdyn.perm_p);

  if lpdyn.prev_p = nil
    then begin                         {at top level}
      lpdyn.perm_p^.prev_p := nil;
      end
    else begin                         {there is a parent level}
      lpdyn.perm_p^.prev_p := lpdyn.prev_p^.perm_p;
      end
    ;
  lpdyn.perm_p^.line_p := lpdyn.line_p; {point perm desc to its text line}
  end;
