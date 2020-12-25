{   Public include file for the FLINE library.  This library manages lines from
*   files or separate collections of line kept in memory where they can be
*   accessed without any explicit I/O operations.
}
const
  fline_subsys_k = -73;                {FLINE library subsystem ID}

type
  fline_line_p_t = ^fline_line_t;

  fline_lcoll_k_t = (                  {ID for types of collections of text lines}
    fline_lcoll_file_k,                {copy of a file}
    fline_lcoll_lmem_k);               {local collection of lines only in memory}

  fline_file_p_t = ^fline_file_t;
  fline_file_t = record                {info about one "file" or collections of lines}
    lcoll: fline_lcoll_k_t;            {type of this collection of lines}
    first_p: fline_line_p_t;           {pointer to first line}
    last_p: fline_line_p_t;            {pointer to last line}
    case fline_lcoll_k_t of            {what kind of collection is this ?}
fline_lcoll_file_k: (                  {copy of file system file}
      file_tnam_p: string_var_p_t;     {full file treename}
      );
fline_lcoll_lmem_k: (                  {named collection in memory}
      lmem_name_p: string_var_p_t;     {name of this snippet}
      );
    end;

  fline_flist_ent_p_t = ^fline_flist_ent_t;
  fline_flist_ent_t = record           {files list entry}
    next_p: fline_flist_ent_p_t;       {pointer to next file in list}
    file_p: fline_file_p_t;            {pointer to file for this list entry}
    end;

  fline_line_t = record                {info about one input file line}
    next_p: fline_line_p_t;            {pointer to next input line this file, NIL = last}
    file_p: fline_file_p_t;            {pointer to file this line is from}
    lnum: sys_int_machine_t;           {1-N line number of this line}
    str_p: string_var_p_t;             {pointer to string for this line}
    end;

  fline_pos_p_t = ^fline_pos_t;
  fline_pos_t = record                 {info about one character position}
    line_p: fline_line_p_t;            {line containing the character}
    ind: sys_int_machine_t;            {1-N index into line, 0 before}
    end;

  fline_crange_p_t = ^fline_crange_t;
  fline_crange_t = record              {character range within a file}
    first: fline_pos_t;                {first character of the range}
    last: fline_pos_t;                 {last character of the range}
    end;

  fline_hpos_p_t = ^fline_hpos_t;
  fline_hpos_t = record                {position within hierarchy of files}
    level: sys_int_machine_t;          {nesting level, 0 at top file}
    file_p: fline_file_p_t;            {pointer to the current file}
    pos: fline_pos_t;                  {current position within this file}
    prev_p: fline_hpos_p_t;            {pointer to position within parent file}
    end;

  fline_p_t = ^fline_t;
  fline_t = record                     {state for one use of this library}
    mem_p: util_mem_context_p_t;       {points to context for dynamic memory}
    file_first_p: fline_flist_ent_p_t; {points to first files list entry}
    file_last_p: fline_flist_ent_p_t;  {points to last files list entry}
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
