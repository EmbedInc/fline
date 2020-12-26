{   High level handling of collections of lines.
}
module fline_coll;
define fline_coll_new;
define fline_coll_new_file;
define fline_coll_new_lmem;
define fline_coll_find_file;
define fline_coll_find_lmem;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_COLL_NEW (FL, COLLTYP, COLL_P)
*
*   Create a new collection of type COLLTYP.  The type-specific fields are not
*   filled in.
}
procedure fline_coll_new (             {create new empty collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      colltyp: fline_colltyp_k_t;  {type of the new collection}
  out     coll_p: fline_coll_p_t);     {pointer to new coll, type-specific not filled in}
  val_param;

var
  ent_p: fline_flist_ent_p_t;          {points to new collections list entry}

begin
  util_mem_grab (                      {alloc mem for the new collection}
    sizeof(coll_p^), fl.mem_p^, false, coll_p);
  util_mem_grab (                      {alloc mem for the new list entry}
    sizeof(ent_p^), fl.mem_p^, false, ent_p);

  coll_p^.colltyp := colltyp;          {fill in fixed fields of the collection}
  coll_p^.first_p := nil;
  coll_p^.last_p := nil;

  ent_p^.next_p := nil;                {fill in new collections list entry}
  ent_p^.coll_p := coll_p;

  if fl.coll_last_p = nil              {link new entry to end of list}
    then begin
      fl.coll_first_p := ent_p;
      end
    else begin
      fl.coll_last_p^.next_p := ent_p;
      end
    ;
  fl.coll_last_p := ent_p;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_COLL_NEW_FILE (FL, TNAM, COLL_P)
*
*   Create a new collection of type FILE.
}
procedure fline_coll_new_file (        {create new empty collection, type FILE}
  in out  fl: fline_t;                 {FLINE library use state}
  in      tnam: univ string_var_arg_t; {absolute file treename}
  out     coll_p: fline_coll_p_t);     {returned pointer to the new collection}
  val_param;

begin
  fline_coll_new (fl, fline_colltyp_file_k, coll_p); {create new collection}
  string_alloc (                       {create the treename string}
    tnam.len, fl.mem_p^, false, coll_p^.file_tnam_p);
  string_copy (tnam, coll_p^.file_tnam_p^); {fill in the file treename}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_COLL_NEW_LMEM (FL, NAME, COLL_P)
*
*   Create a new collection of type LMEM.
}
procedure fline_coll_new_lmem (        {create new empty collection, type LMEM}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {returned pointer to the new collection}
  val_param;

begin
  fline_coll_new (fl, fline_colltyp_lmem_k, coll_p); {create new collection}
  string_alloc (                       {create the name string}
    name.len, fl.mem_p^, false, coll_p^.lmem_name_p);
  string_copy (name, coll_p^.lmem_name_p^); {fill in collection name}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_COLL_FIND_FILE (FL, TNAM, COLL_P)
*
*   Find the existing FILE collection for the file TNAM.  TNAM must be the full
*   absolute treename of the file.  COLL_P is returned NIL if the collection
*   does not exist.
}
procedure fline_coll_find_file (       {find existing FILE collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      tnam: univ string_var_arg_t; {full file absolute treename}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param;

var
  ent_p: fline_flist_ent_p_t;          {points to current collections list entry}

label
  next_ent;

begin
  coll_p := nil;                       {init to the collection was not found}

  ent_p := fl.coll_first_p;            {init to first list entry}
  while ent_p <> nil do begin          {scan the list}
    if ent_p^.coll_p^.colltyp <> fline_colltyp_file_k {not a FILE coll type ?}
      then goto next_ent;
    if not string_equal (ent_p^.coll_p^.file_tnam_p^, tnam) {not this file ?}
      then goto next_ent;
    coll_p := ent_p^.coll_p;           {return pointer to this collection}
    return;
next_ent:                              {advance to the next list entry}
    ent_p := ent_p^.next_p;
    end;                               {back to check this new list entry}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_COLL_FIND_LMEM (FL, NAME, COLL_P)
*
*   Find the existing LMEM collection of name NAME.  COLL_P is returned NIL if
*   the collection does not exist.
}
procedure fline_coll_find_lmem (       {find existing LMEM collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param;

var
  ent_p: fline_flist_ent_p_t;          {points to current collections list entry}

label
  next_ent;

begin
  coll_p := nil;                       {init to the collection was not found}

  ent_p := fl.coll_first_p;            {init to first list entry}
  while ent_p <> nil do begin          {scan the list}
    if ent_p^.coll_p^.colltyp <> fline_colltyp_lmem_k {not a LMEM coll type ?}
      then goto next_ent;
    if not string_equal (ent_p^.coll_p^.lmem_name_p^, name) {not this lmem ?}
      then goto next_ent;
    coll_p := ent_p^.coll_p;           {return pointer to this collection}
    return;
next_ent:                              {advance to the next list entry}
    ent_p := ent_p^.next_p;
    end;                               {back to check this new list entry}
  end;
