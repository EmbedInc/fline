{   Public include file for the FLINE library.  This library manages named
*   collections of text lines.  These can be contents of files, but can also be
*   from other sources.  All data is kept in memory where applications can
*   reference it with pointers.
}
const
  fline_subsys_k = -73;                {FLINE library subsystem ID}

type
  fline_line_p_t = ^fline_line_t;
  fline_p_t = ^fline_t;

  fline_colltyp_k_t = (                {ID for type of collections of text lines}
    fline_colltyp_file_k,              {copy of a file}
    fline_colltyp_lmem_k);             {local collection of lines only in memory}

  fline_coll_p_t = ^fline_coll_t;
  fline_coll_t = record                {info about one collection of lines}
    fline_p: fline_p_t;                {pointer to library use this coll is within}
    first_p: fline_line_p_t;           {pointer to first line}
    last_p: fline_line_p_t;            {pointer to last line}
    colltyp: fline_colltyp_k_t;        {type of this collection}
    case fline_colltyp_k_t of          {what kind of collection is this ?}
fline_colltyp_file_k: (                {copy of file system file}
      file_tnam_p: string_var_p_t;     {full file treename}
      );
fline_colltyp_lmem_k: (                {named collection in memory}
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
    coll_p: fline_coll_p_t;            {pointer to collection line is within}
    line_p: fline_line_p_t;            {line containing the character, NIL before first}
    ind: sys_int_machine_t;            {1-N char index, 0 before, len+1 after}
    end;

  fline_hier_p_t = ^fline_hier_t;
  fline_hier_t = record                {position within hierarchy of collections}
    prev_p: fline_hier_p_t;            {points to position within parent collection}
    level: sys_int_machine_t;          {nesting level, 0 at top file}
    pos: fline_pos_t;                  {position within the current file}
    end;

  fline_t = record                     {state for one use of this library}
    mem_p: util_mem_context_p_t;       {points to context for dynamic memory}
    coll_first_p: fline_flist_ent_p_t; {points to start of collections list}
    coll_last_p: fline_flist_ent_p_t;  {points to end of collections list}
    end;
{
*   Functions and subroutines.
}
procedure fline_coll_find_file (       {find existing FILE collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      tnam: univ string_var_arg_t; {full file absolute treename}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param; extern;

procedure fline_coll_find_lmem (       {find existing LMEM collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param; extern;

procedure fline_coll_new (             {create new empty collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      colltyp: fline_colltyp_k_t;  {type of the new collection}
  out     coll_p: fline_coll_p_t);     {pointer to new coll, type-specific not filled in}
  val_param; extern;

procedure fline_coll_new_file (        {create new empty collection, type FILE}
  in out  fl: fline_t;                 {FLINE library use state}
  in      tnam: univ string_var_arg_t; {absolute file treename}
  out     coll_p: fline_coll_p_t);     {returned pointer to the new collection}
  val_param; extern;

procedure fline_coll_new_lmem (        {create new empty collection, type LMEM}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {returned pointer to the new collection}
  val_param; extern;

procedure fline_file_get (             {find or create contents of a text file}
  in out  fl: fline_t;                 {FLINE library use state}
  in      fnam: univ string_var_arg_t; {file name}
  out     coll_p: fline_coll_p_t;      {returned pointer to the text lines collection}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure fline_lib_end (              {end a use of the FLINE library}
  in out  fline_p: fline_p_t);         {pointer to lib use state, returned NIL}
  val_param; extern;

procedure fline_lib_new (              {create new use of the FLINE library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     fline_p: fline_p_t;          {returned pointer to new library use state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure fline_line_add (             {add line to end of collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  coll: fline_coll_t;          {the collection to add to}
  in      line: univ string_var_arg_t); {the text line to add}
  val_param; extern;
