{   Public include file for the FLINE library.  This library manages named
*   collections of text lines.  These can be contents of files, but can also be
*   from other sources.  All data is kept in memory where applications can
*   reference it with pointers.
}
const
  fline_subsys_k = -73;                {FLINE library subsystem ID}

type
  fline_line_p_t = ^fline_line_t;

  fline_coll_k_t = (                   {ID for type of collections of text lines}
    fline_coll_file_k,                 {copy of a file}
    fline_coll_lmem_k);                {local collection of lines only in memory}

  fline_coll_p_t = ^fline_coll_t;
  fline_coll_t = record                {info about one collection of lines}
    coll: fline_coll_k_t;              {type of this collection}
    first_p: fline_line_p_t;           {pointer to first line}
    last_p: fline_line_p_t;            {pointer to last line}
    case fline_coll_k_t of             {what kind of collection is this ?}
fline_coll_file_k: (                   {copy of file system file}
      file_tnam_p: string_var_p_t;     {full file treename}
      );
fline_coll_lmem_k: (                   {named collection in memory}
      lmem_name_p: string_var_p_t;     {name of this snippet}
      );
    end;

  fline_flist_ent_p_t = ^fline_flist_ent_t;
  fline_flist_ent_t = record           {collections list entry}
    next_p: fline_flist_ent_p_t;       {pointer to next list entry}
    coll_p: fline_coll_p_t;            {pointer to collection for this list entry}
    end;

  fline_line_t = record                {one line in a collection}
    next_p: fline_line_p_t;            {points to next line in this collection}
    coll_p: fline_coll_p_t;            {points to collection this line is in}
    lnum: sys_int_machine_t;           {1-N line number of this line}
    str_p: string_var_p_t;             {pointer to string for this line}
    end;

  fline_pos_p_t = ^fline_pos_t;
  fline_pos_t = record                 {character position within line}
    line_p: fline_line_p_t;            {line containing the character}
    ind: sys_int_machine_t;            {1-N char index, 0 before, len+1 after}
    end;

  fline_hpos_p_t = ^fline_hpos_t;
  fline_hpos_t = record                {position within hierarchy of collections}
    prev_p: fline_hpos_p_t;            {points to position within parent collection}
    level: sys_int_machine_t;          {nesting level, 0 at top file}
    pos: fline_pos_t;                  {position within the current file}
    end;

  fline_p_t = ^fline_t;
  fline_t = record                     {state for one use of this library}
    mem_p: util_mem_context_p_t;       {points to context for dynamic memory}
    coll_first_p: fline_flist_ent_p_t; {points to start of collections list}
    coll_last_p: fline_flist_ent_p_t;  {points to end of collections list}
    end;
{
*   Functions and subroutines.
}
procedure fline_end (                  {end a use of the FLINE library}
  in out  fline_p: fline_p_t);         {pointer to lib use state, returned NIL}
  val_param; extern;

procedure fline_new (                  {create new use of the FLINE library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     fline_p: fline_p_t;          {returned pointer to new library use state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;
