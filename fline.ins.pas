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
    fline_colltyp_any_k,               {for matching any collection type}
    fline_colltyp_file_k,              {copy of a file}
    fline_colltyp_lmem_k,              {local collection of lines only in memory}
    fline_colltyp_virt_k);             {just file name for virtual reference}

  fline_coll_p_t = ^fline_coll_t;
  fline_coll_t = record                {info about one collection of lines}
    fline_p: fline_p_t;                {points to library use this coll is within}
    first_p: fline_line_p_t;           {points to first line}
    last_p: fline_line_p_t;            {points to last line}
    name_p: string_var_p_t;            {points to collection name, treename if from file}
    colltyp: fline_colltyp_k_t;        {type of this collection}
    case fline_colltyp_k_t of          {what kind of collection is this ?}
fline_colltyp_file_k: (                {copy of file system file}
      );
fline_colltyp_lmem_k: (                {named collection in memory}
      );
fline_colltyp_virt_k: (                {virtual file, ref only, doesn't contain lines}
      );
    end;

  fline_flist_ent_p_t = ^fline_flist_ent_t;
  fline_flist_ent_t = record           {collections list entry}
    next_p: fline_flist_ent_p_t;       {pointer to next list entry}
    coll_p: fline_coll_p_t;            {pointer to collection for this list entry}
    end;

  fline_virtlin_p_t = ^fline_virtlin_t;
  fline_virtlin_t = record             {virtual source of a line}
    coll_p: fline_coll_p_t;            {points to collection this line is in}
    lnum: sys_int_machine_t;           {1-N number of line within the file}
    end;

  fline_line_t = record                {one line in a collection}
    prev_p: fline_line_p_t;            {points to previous line in this collection}
    next_p: fline_line_p_t;            {points to next line in this collection}
    coll_p: fline_coll_p_t;            {points to collection this line is in}
    lnum: sys_int_machine_t;           {1-N line number of this line}
    str_p: string_var_p_t;             {pointer to string for this line}
    virt_p: fline_virtlin_p_t;         {points to virtual source line info}
    end;

  fline_cpos_p_t = ^fline_cpos_t;
  fline_cpos_t = record                {character position within line}
    coll_p: fline_coll_p_t;            {pointer to collection line is within}
    line_p: fline_line_p_t;            {line containing the character, NIL at end}
    ind: sys_int_machine_t;            {1-N char index, 0 before, len+1 after}
    end;

  fline_hier_p_t = ^fline_hier_t;
  fline_hier_t = record                {position within hierarchy of collections}
    prev_p: fline_hier_p_t;            {points to parent hierarchy level}
    level: sys_int_machine_t;          {global nesting level, 0 at top}
    blklev: sys_int_machine_t;         {block nesting level, 0 at top}
    cpos: fline_cpos_t;                {character position within this collection}
    end;

  fline_t = record                     {state for one use of this library}
    mem_p: util_mem_context_p_t;       {points to context for dynamic memory}
    coll_first_p: fline_flist_ent_p_t; {points to start of collections list}
    coll_last_p: fline_flist_ent_p_t;  {points to end of collections list}
    end;
{
*   Functions and subroutines.
}
procedure fline_block_delete (         {delete entire current block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {ret first lev above block, NIL deleted top block}
  val_param; extern;

procedure fline_block_getnext_line (   {advance to next input line in block, return line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of block}
  val_param; extern;

procedure fline_block_getnext_str (    {advance to next input line in block, return string}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of block}
  val_param; extern;

procedure fline_block_new_copy (       {start hier block, copy original position}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {pointer to parent hiearchy level, NIL create top}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level}
  val_param; extern;

procedure fline_block_new_line (       {start hier block at specific line}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {pointer to parent hiearchy level, NIL create top}
  in var  line: fline_line_t;          {position will be before start of this line}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level}
  val_param; extern;

function fline_block_nextline (        {to next line in current block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t)      {pointer to position within hierarcy, may be updated}
  :boolean;                            {TRUE: advanced, not hit end of block}
  val_param; extern;

function fline_block_level (           {get nesting level within current block}
  in      hier_p: fline_hier_p_t)      {pointer to hiearchy level inquiring about}
  :sys_int_machine_t;                  {nesting level, 0 at block top, -1 for no hierarchy}
  val_param; extern;

procedure fline_block_pop (            {pop back one level within hierarchy block}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {will point to parent, NIL popped from top of block}
  val_param; extern;

function fline_char (                  {get current character, advance to next}
  in out  cpos: fline_cpos_t;          {current character position, updated to next}
  out     ch: char)                    {returned character, 0 for none}
  :boolean;                            {TRUE: returning char, FALSE: end of line}
  val_param; extern;

procedure fline_coll_find (            {find existing FILE collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name, must match exactly}
  in      colltyp: fline_colltyp_k_t;  {type of the new collection}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param; extern;

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

procedure fline_coll_find_virt (       {find existing VIRT collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {pointer to collection, NIL not found}
  val_param; extern;

procedure fline_coll_line_first (      {get pointer to first line of collection}
  in      coll: fline_coll_t;          {the collection inquiring about}
  out     line_p: fline_line_p_t);     {returned pointer to first line, NIL if no lines}
  val_param; extern;

procedure fline_coll_new (             {create new empty collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: string_var_arg_t;      {collection name}
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

procedure fline_coll_new_virt (        {create new empty collection, type VIRT}
  in out  fl: fline_t;                 {FLINE library use state}
  in      name: univ string_var_arg_t; {collection name}
  out     coll_p: fline_coll_p_t);     {returned pointer to the new collection}
  val_param; extern;

procedure fline_cpos_coll (            {set char position to before collection}
  out     cpos: fline_cpos_t;          {updated character position}
  in var  coll: fline_coll_t);         {the collection of lines}
  val_param; extern;

function fline_cpos_eol (              {determine whether at end of line}
  in      cpos: fline_cpos_t)          {character position}
  :boolean;                            {at end of line, includes before start of coll}
  val_param; extern;

procedure fline_cpos_init (            {init character position to default or benign values}
  in out  cpos: fline_cpos_t);         {character position to initialize}
  val_param; extern;

procedure fline_cpos_set_line_aft (    {set character position to after end of line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_cpos_set_line_at (     {set character position to start of line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_cpos_set_line_bef (    {set character position to before line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_cpos_getnext_line (    {advance to next input line in coll, return line}
  in out  cpos: fline_cpos_t;          {character position, updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of collection}
  val_param; extern;

procedure fline_cpos_getnext_str (     {advance to next input line in coll, return string}
  in out  cpos: fline_cpos_t;          {character position, updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of collection}
  val_param; extern;

function fline_cpos_nextline (         {advance to next line in collection of lines}
  in out  cpos: fline_cpos_t)          {character position to update}
  :boolean;                            {TRUE: advanced, not hit end of collection}
  val_param; extern;

procedure fline_file_get (             {find or create contents of a text file}
  in out  fl: fline_t;                 {FLINE library use state}
  in      fnam: univ string_var_arg_t; {file name}
  out     coll_p: fline_coll_p_t;      {returned pointer to the text lines collection}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure fline_file_get_suff (        {find or create contents of a text file, fnam suffixex}
  in out  fl: fline_t;                 {FLINE library use state}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {file name suffixes, blank separated}
  out     coll_p: fline_coll_p_t;      {returned pointer to the text lines collection}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function fline_hier_char (             {get current character, advance to next}
  in out  hier: fline_hier_t;          {position within hierarchy, updated to next char}
  out     ch: char)                    {returned character, 0 for none}
  :boolean;                            {TRUE: returning char, FALSE: end of line}
  val_param; extern;

procedure fline_hier_create (          {create a new files hierarchy stack}
  in out  fl: fline_t;                 {FLINE library use state}
  out     hier_p: fline_hier_p_t;      {returned pointer to top level of new hierarchy}
  in var  coll: fline_coll_t);         {collection for top "file" of hierarchy}
  val_param; extern;

procedure fline_hier_delete (          {delete whole hierarchy}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {delete this level and all parents, returned NIL}
  val_param; extern;

procedure fline_hier_get_line (        {get pointer to current line}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     line_p: fline_line_p_t);     {pointer to the line, NIL if before first}
  val_param; extern;

procedure fline_hier_get_linenx (      {get pointer to next line, don't change position}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     line_p: fline_line_p_t);     {pointer to the next line, NIL if end of all input}
  val_param; extern;

procedure fline_hier_get_str (         {get pointer to current line string}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     str_p: string_var_p_t);      {pointer to line string, NIL if before first}
  val_param; extern;

procedure fline_hier_getnext_line (    {advance to next input line in hier, return line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of all input}
  val_param; extern;

procedure fline_hier_getnext_str (     {advance to next input line in hier, return string}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pointer to position within hierarcy, may be updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of all input}
  val_param; extern;

function fline_hier_level (            {get hierarchy level}
  in      hier_p: fline_hier_p_t)      {pointer to hiearchy level inquiring about}
  :sys_int_machine_t;                  {nesting level, 0 at top, -1 for no hierarchy}
  val_param; extern;

function fline_hier_lnum (             {get line number at a hier level}
  in      hier: fline_hier_t)          {descriptor for the hierarchy level}
  :sys_int_machine_t;                  {1-N line number, 0 before first}
  val_param; extern;

procedure fline_hier_name (            {get name of collection at a hier level}
  in      hier: fline_hier_t;          {descriptor for the hierarchy level}
  out     name_p: string_var_p_t);     {returned pointer to collection name}
  val_param; extern;

procedure fline_hier_new (             {low level routine to create new hierchy descriptor}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {pointer to parent, NIL for create top level}
  out     hier_p: fline_hier_p_t);     {returned pointer to new hier level, CPOS not filled in}
  val_param; extern;

procedure fline_hier_new_coll (        {create new hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {points to parent hierarchy level, if any}
  out     hier_p: fline_hier_p_t;      {returned pointing to new hierarchy level}
  in var  coll: fline_coll_t);         {collection of lines new level will refer to}
  val_param; extern;

procedure fline_hier_new_line (        {create new hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in      parent_p: fline_hier_p_t;    {points to parent hierarchy level, if any}
  out     hier_p: fline_hier_p_t;      {returned pointing to new hierarchy level}
  in var  line: fline_line_t);         {line to set char position before start of}
  val_param; extern;

function fline_hier_nextline (         {to next line in current hierarchy level}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t)      {pointer to position within hierarcy, may be updated}
  :boolean;                            {TRUE: advanced, not hit end of all input}
  val_param; extern;

procedure fline_hier_pop (             {pop back to previous hier level, delete old}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t);     {will point to parent, NIL when popped top level}
  val_param; extern;

procedure fline_hier_push_coll (       {new hierarchy level, connect to collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  coll: fline_coll_t);         {collection to read at the new level}
  val_param; extern;

procedure fline_hier_push_line (       {new hierarchy level, to before start of a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in var  line: fline_line_t);         {line to set char position before start of}
  val_param; extern;

procedure fline_hier_push_file (       {new hierarchy level, connect to coll of a file}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {pnt to curr level, will point to child}
  in      fnam: univ string_var_arg_t; {name of file to read at the new level}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure fline_hier_set_line_aft (    {set position to immediately after a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_hier_set_line_at (     {set position to start of a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_hier_set_line_bef (    {set position to immediately before a line}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  hier_p: fline_hier_p_t;      {hier level to set, created when NIL}
  in var  line: fline_line_t);         {line to set position to}
  val_param; extern;

procedure fline_lib_end (              {end a use of the FLINE library}
  in out  fline_p: fline_p_t);         {pointer to lib use state, returned NIL}
  val_param; extern;

procedure fline_lib_new (              {create new use of the FLINE library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     fline_p: fline_p_t;          {returned pointer to new library use state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure fline_line_add_end (         {add line to end of collection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  coll: fline_coll_t;          {the collection to add to}
  in      str: univ string_var_arg_t); {text string to add as a new line}
  val_param; extern;

function fline_line_lnum (             {get number of a line within collection}
  in out  line: fline_line_t)          {the line inquiring about}
  :sys_int_machine_t;                  {1-N line number, 0 before start}
  val_param; extern;

function fline_line_lnum_virt (        {get number of a line within virtual collection}
  in out  line: fline_line_t)          {the line inquiring about}
  :sys_int_machine_t;                  {1-N line number, 0 before start}
  val_param; extern;

procedure fline_line_name (            {get name of collection that line is in}
  in out  line: fline_line_t;          {the line inquiring about}
  out     name_p: string_var_p_t);     {returned pointing to collection name}
  val_param; extern;

procedure fline_line_name_virt (       {get name of virtual collection that line is in}
  in out  line: fline_line_t;          {the line inquiring about}
  out     name_p: string_var_p_t);     {returned pointing to collection name}
  val_param; extern;

procedure fline_line_virt (            {add virtual reference to existing line}
  in out  line: fline_line_t;          {the line to add virtual reference to}
  in out  vcoll: fline_coll_t;         {collection being virtually referenced}
  in      lnum: sys_int_machine_t);    {line number within the collection}
  val_param; extern;

procedure fline_line_virt_last (       {add virtual ref to last line of collection}
  in out  coll: fline_coll_t;          {add virt ref to last line of this coll}
  in out  vcoll: fline_coll_t;         {collection being virtually referenced}
  in      lnum: sys_int_machine_t);    {line number of virtual reference}
  val_param; extern;
